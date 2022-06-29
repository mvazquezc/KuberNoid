package main

import (
	"context"
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"path/filepath"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

type Pod struct {
	Namespace string `json:"namespace"`
	PodName   string `json:"pod"`
}
type PodsOutput struct {
	Pods []Pod `json:"pods"`
}

type PodListerHandler struct {
	Namespace  *string
	KubeClient dynamic.Interface
}

func listen(port string, podListerHandler PodListerHandler) {
	router := mux.NewRouter()
	router.HandleFunc("/", podListerHandler.podLister).Methods("GET")
	router.HandleFunc("/delete", podListerHandler.podDeleter).Methods("POST")
	c := cors.New(cors.Options{AllowedOrigins: []string{"*"}})
	handler := c.Handler(router)
	log.Fatal(http.ListenAndServe(":"+port, handler))
	log.Printf("Listening on port %s", port)
}

func (plh *PodListerHandler) podDeleter(w http.ResponseWriter, r *http.Request) {
	//	w.Header().Set("Access-Control-Allow-Origin", "*")
	decoder := json.NewDecoder(r.Body)
	var pod Pod
	err := decoder.Decode(&pod)
	if err != nil {
		// No json data received
		if err.Error() != "EOF" {
			panic(err)
		}
	}
	var output string
	if len(pod.Namespace) < 1 || len(pod.PodName) < 1 {
		log.Println("Pod namespace or pod name not received")
		output = "Pod namespace or pod name not received"
	} else {
		log.Printf("Received namespace %s and pod %s", pod.Namespace, pod.PodName)
		// Delete the pod
		podRes := schema.GroupVersionResource{Group: "", Version: "v1", Resource: "pods"}
		deletePolicy := metav1.DeletePropagationForeground
		deleteOptions := metav1.DeleteOptions{
			PropagationPolicy: &deletePolicy,
		}
		err := plh.KubeClient.Resource(podRes).Namespace(pod.Namespace).Delete(context.TODO(), pod.PodName, deleteOptions)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		output = "Deleted pod " + pod.PodName + " in namespace " + pod.Namespace

	}
	_, err = w.Write([]byte(output))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

}

func (plh *PodListerHandler) podLister(w http.ResponseWriter, r *http.Request) {
	//	w.Header().Set("Access-Control-Allow-Origin", "*")
	// Pod Resource
	podRes := schema.GroupVersionResource{Group: "", Version: "v1", Resource: "pods"}

	if *plh.Namespace == "" {
		log.Printf("Listing pods in all namespaces\n")
	} else {
		log.Printf("Listing pods in namespace %s\n", *plh.Namespace)
	}

	var output PodsOutput
	var pod Pod

	//Dynamic client examples can be found here https://github.com/kubernetes/client-go/blob/v0.24.1/examples/dynamic-create-update-delete-deployment/main.go

	list, err := plh.KubeClient.Resource(podRes).Namespace(*plh.Namespace).List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		panic(err)
	}

	for _, d := range list.Items {
		// Extract namespace
		podNamespace, _, err := unstructured.NestedString(d.Object, "metadata", "namespace")
		if err != nil {
			log.Printf("Error getting namespace %v", err)
			continue
		}
		podName, _, err := unstructured.NestedString(d.Object, "metadata", "name")
		if err != nil {
			log.Printf("Error getting name %v", err)
			continue
		}
		podRunning, _, err := unstructured.NestedString(d.Object, "status", "phase")
		if err != nil {
			log.Printf("Error getting status %v", err)
			continue
		}
		if podRunning == "Running" {
			pod = Pod{podNamespace, podName}
			output.Pods = append(output.Pods, pod)

			log.Printf("Got running pod %s in namespace %s", podName, podNamespace)
		}

	}
	js, err := json.Marshal(output)
	js = append(js, "\n"...)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_, err = w.Write([]byte(js))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func main() {

	var kubeconfig *string

	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}

	// "" namespace means list all namespaces
	namespace := flag.String("namespace", "", "Namespace to filter subscriptions, default is all namespaces")
	port := flag.String("port", "9000", "Port where the lister will listen for connections, default is 9000")
	flag.Parse()

	// Protected namespaces
	//protectedNamespaces := []string{"kube-system", "open-cluster-management"}

	// Try to get the config from the in-cluster client
	config, err := rest.InClusterConfig()
	if err != nil {
		log.Println("Error getting in-cluster config. Trying to get config from local kubeconfig or flags")
		config, err = clientcmd.BuildConfigFromFlags("", *kubeconfig)
		if err != nil {
			panic(err)
		}
	}

	client, err := dynamic.NewForConfig(config)
	if err != nil {
		panic(err)
	}

	// Start http server
	podListerHandler := &PodListerHandler{Namespace: namespace, KubeClient: client}
	listen(*port, *podListerHandler)

}

//func contains(s []string, e string) bool {
//    for _, a := range s {
//        if a == e {
//            return true
//        }
//    }
//    return false
//}
