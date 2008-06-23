

on http_post(the_data, the_url)
	set the_command to "curl -d " & quoted form of the_data & " " & the_url
	return do shell script (the_command as Unicode text)
end http_post

on open_location(x)
	open location x
end open_location