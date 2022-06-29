extends StaticBody2D


func delete_brick():
	if self.has_meta("namespace") and self.has_meta("podname"):
		var brick_namespace = self.get_meta("namespace")
		var brick_podname = self.get_meta("podname")
		print("Remove pod with namespace " + brick_namespace + " and name " + brick_podname)
		var http_request = HTTPRequest.new()
		add_child(http_request)
		#var pod_data = '{"namespace": "' + brick_namespace + '", "pod": "' + brick_podname + '"}'
		var pod_data = {}
		pod_data["namespace"] = brick_namespace
		pod_data["pod"] = brick_podname
		var query = JSON.print(pod_data)
		var headers = ["Content-Type: application/json"]
		http_request.request(GameOptions.pod_lister_url + "/delete", headers, false, HTTPClient.METHOD_POST, query)
	$AnimatedSprite.visible = false
	# Give some time for the request
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(0.5), "timeout")
	
	queue_free()


func destroy_brick():
	if self.has_meta("namespace") and self.has_meta("podname"):
		var brick_namespace = self.get_meta("namespace")
		var brick_podname = self.get_meta("podname")
		print("Remove pod with namespace " + brick_namespace + " and name " + brick_podname)
	queue_free()
