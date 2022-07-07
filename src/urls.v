module main

import os

//
// TODO: Can remove, fixed in V.
//
fn get_url_source(url string, out string) string {
	format_url := url.replace('&amp;', '&')
	mut cmd := ['curl', '"' + format_url + '"', '-L']

	if out.len > 1 {
		cmd << '--output'
		cmd << os.real_path(out)
	}

	result := run_exec(cmd)

	return result.join('')
}

fn download_to(url string, path string) {
	get_url_source(url, path)
}
