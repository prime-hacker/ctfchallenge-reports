# Intro
On the website [ctfchallenge.com](https://ctfchallenge.com), the definition of this challenge is as follows
>VulnTraining provide training services to their clients but they could do with some training themselves, security training that is!

**CTF level**: hard.  
**Main website**: [www.vulntraining.co.uk](http://www.vulntraining.co.uk/)    
**Screenshot**:   ![vulntraining.co.uk](screenshots/ss1.png)
# Walk Through
1. We usually start by surfing the website but in the case of this website it is really simple, just the home page and not a single link other than it.
2. So we do some subdomain discovery by
	1. Using *dnsrecon*: `dnsrecon -d vulntraining.co.uk -D ~/wordlists/subdomains.txt -t brt` but **0 records found**
	2. Searching on [crt.sh](https://crt.sh/?q=vulntraining.co.uk)we found
		1. `billing.vulntraining.co.uk`
		2. `c867fc3a.vulntraining.co.uk`   ![Subdomains](screenshots/ss2.png) 
3. Had a quick look at each one of these subdomains. Found that
	1. `c867fc3a.vulntraining.co.uk` showed a flag   ![Flag 1](screenshots/ss3.png)  **Found Flag 1**
	2. `billing.vulntraining.co.uk` showed a login forum   ![Login Forum](screenshots/ss4.png)
4. We can start by entering any data in username and password fields to see how the website reacts with it and it showed the error message `Username is invalid`   ![Invalid Username](screenshots/ss5.png)   So we can enumerate usernames