## 📝 Script Description
This Bash script is designed to check whether web shells are still accessible (live) by verifying their HTTP response status code. Unlike the original version that relied on detecting specific content in the response body, this improved script considers a shell "live" if it responds with an HTTP 200 OK status — even if it returns no visible output.

## 🔧 Features:
- Reads a list of potential shell URLs from a text file
- Uses curl with a timeout and custom user-agent
- Identifies live shells purely based on HTTP 200 status code
- Logs all live shell URLs to live-shell.txt
- More reliable for detecting silent or minimal-output shells

### Usage

```sh
usage: bash backdoorchecker.sh list.txt
```
