# Intro
On the website [ctfchallenge.com](https://ctfchallenge.com), the definition of this challenge is as follows
>VulnTraining provide training services to their clients but they could do with some training themselves, security training that is!

**CTF level**: hard.  
**Number of flags**: 11  
**Main website**: [www.vulntraining.co.uk](http://www.vulntraining.co.uk/)    
**Screenshot**:   ![vulntraining.co.uk](screenshots/ss1.png)
# Things of Value
Here, we add anything we find of value incrementally during our walk through.
## Subdomains
1. billing.vulntraining.co.uk *found from subdomain discovery in step 2*
2. c867fc3a.vulntraining.co.uk *found from subdomain discovery in step 2*
## Endpoints
1. billing.vulntraining.co.uk/login -> *found from subdomain discovery in step 2*
2. www.vulntraining.co.uk/.git/HEAD -> *found from content discovery in step 5*
3. www.vulntraining.co.uk/.git/config -> *found from content discovery in step 5*
4. www.vulntraining.co.uk/.git/index -> *found from content discovery in step 5*
5. www.vulntraining.co.uk/framework -> *found from content discovery in step 5*
6. www.vulntraining.co.uk/robots.txt -> *found from content discovery in step 5*
7. www.vulntraining.co.uk/server/ -> *found from content discovery in step 5*
8. www.vulntraining.co.uk/server/login -> *was directed to it through a location header*
9. vulntraining.co.uk/php-my-s3cret-admin -> *found from endpoint 7*
## Credentials
1. Database creds: `vulntraining:#x7QE1Jg&cNO`
2. Billing account creds: `dominic.bryant:987654321`

# Walk Through
1. We usually start by surfing the website but in the case of this website it is really simple, just the home page and not a single link other than it.
2. So we do some subdomain discovery by
	1. Using *dnsrecon*: `dnsrecon -d vulntraining.co.uk -D ~/wordlists/subdomains.txt -t brt` but **0 records found**
	2. Searching on [crt.sh](https://crt.sh/?q=vulntraining.co.uk) we found
		1. `billing.vulntraining.co.uk`
		2. `c867fc3a.vulntraining.co.uk`   ![Subdomains](screenshots/ss2.png) 
3. Had a quick look at each one of these subdomains. Found that
	1. `c867fc3a.vulntraining.co.uk` showed a flag   ![Flag 1](screenshots/ss3.png)       **Found Flag 1**
	3. `billing.vulntraining.co.uk` showed a login forum   ![Login Forum](screenshots/ss4.png)
4. We can start by entering any data in username and password fields to see how the website reacts with it and it showed the error message `Username is invalid`   ![Invalid Username](screenshots/ss5.png)   So we can enumerate usernames
	1. Username enumeration using **ffuf**: `ffuf -w ~/wordlists/usernames.txt   -X POST -d "username=FUZZ&password=werwe" -t 1 -p 0.1 -H "Cookie: ctfchallenge=$ctfchallenge_cookie" -H "Content-Type: application/x-www-form-urlencoded" -u http://billing.vulntraining.co.uk/login -mc all -fr "Username is invalid"` but **no username in this list is valid** so we have to find usernames in another way
5. We try discovering any hidden endpoint in `www.vulntraining.co.uk` by bruteforcing it with *ffuf*: `ffuf -w ~/wordlists/content.txt -t 1 -p 0.1  -H "Cookie: ctfchallenge=$ctfchallenge_cookie" -u http://www.vulntraining.co.uk/FUZZ -mc all -fc 404` and found `.git` files and some endpoints   ![.git Files](screenshots/ss6.png)
	1. We start with the simplest `robots.txt` endpoint and we find that it has a disallowed directory that when accessed showed **flag 2**   ![/robots.txt](screenshots/ss7.png)   ![Flag 2](screenshots/ss8.png)   **Found Flag 2**
	2. Then we try accessing this `/server` endpoint that shows `302 status code` which is a relocation, but is showed a snapshot of the server status!   ![Server Status](screenshots/ss9.png)   **Found Flag 4**
	3. We go and visit the admin site of MySQL `http://vulntraining.co.uk/php-my-s3cret-admin` to see what it has and it has a PHPMyAdmin panel!   ![PHPMyAdmin Panel](screenshots/ss10.png)
	4. Tried entering a random username and password to see if we can bruteforce usernames, but it shows a general error message -> `Invalid username and password combination`
6. Going back to the `.git` files we found, I accessed `.git/config` file and found that it had a remote git repository! ![Remote git Repo](screenshots/ss11.png)
	1. We visited this remote repo and found that it is the framework used in the main website and it was private but they had open it to the public   ![Framework of The Website](screenshots/ss13.png)   **Found Flag 6**
	2. Looking at the commits, it has a commit with a message `Removed database creds now we're making this project open source`! We found database credentials `vulntraining:#x7QE1Jg&cNO`!   ![DB Creds](screenshots/ss12.png)
7. Going back to the PHPMyAdmin page we found earlier in *step 5.3*, we try found credentials and it works   ![The Database](screenshots/ss14.png)  
	1. We access this `vulntraining` database and we find `billing_users` table that has a user with a probably hashed password!   ![Billing User](screenshots/ss15.png)  **Found Flag 7**
	2. This password seems to be hashed but not showing completely, so we can bruteforce with the username we got, `dominic.bryant` by **ffuf**:
		1. `ffuf -w ~/wordlists/passwords.txt -X POST -d "username=dominic.bryant&password=FUZZ" -t 2 -p 0.1 -H "Cookie: ctfchallenge=$ctfchallenge_cookie" -H "Content-Type: application/x-www-form-urlencoded" -u http://billing.vulntraining.co.uk/login  -mc all -fr "Password is invalid"`
		2. Voila! We found the password which is `987654321`   ![dominic's Password](screenshots/ss17.png)
8. While reviewing the requests in Burp Proxy history *(a step I do often every now and then during the pentesting process)*, I found that the main website `www.vulntraining.co.uk` has a flag in its response in the HTML `<meta>` tag!   ![Flag in meta tag](screenshots/ss16.png)  **Found Flag 5**
9. We now login in the `billing.vulntraining.co.uk/login` forum with the credentials `dominic.bryant:987654321`   ![Billing Subdomain Home](screenshots/ss18.png)   **Found Flag 8**