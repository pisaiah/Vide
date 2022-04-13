module main

import os

//
// Note: While using Boehm GC, net.http will crash for certain URLs.
// (Unhandled Exception 0xC0000374)
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
