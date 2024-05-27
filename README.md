# Attack and Defending Template Injection with Ruby

Hey AppSecEngineer,

Welcome to the **Attack and Defending Template Injection with Ruby** Course - **Attack** Subject.

Here we shall learn on detecting and exploiting ERB (Embdedded Ruby) template injection in a ruby application

## Template Injections

Template injections, also known as Server-Side Template Injection (SSTI), are a type of security vulnerability that occurs when user input is not properly validated or sanitized before being embedded into templates. Attackers exploit this vulnerability by injecting malicious code into templates, leading to the execution of arbitrary code on the server. This can result in various security risks, including data exposure, remote code execution, or unauthorized access.

## Template Injections in Ruby via ERB

In Ruby, ERB (Embedded Ruby) is a templating system that allows embedding Ruby code within templates. When handling user input in ERB templates, it's crucial to ensure proper validation and sanitization to prevent template injections.

## Example of Template Injection in ERB

### Consider a vulnerable ERB template

```ruby
<p>Hello, <%= user_input %></p>
```

If `user_input` is not properly validated, an attacker could inject malicious Ruby code as

```ruby
user_input = '<%= File.read("/etc/passwd") %>'
```

In this example, the attacker can read sensitive files on the server using the `File.read` method.

Now that we have few of the basic understood, let us start our DIY lab to detect and exploit the same!

## Start DIY lab

- Open a terminal and naviate to `/root/ruby-template-injection-course`
- Just run `./start-app.sh`, this should start a docker container running the app at port `8880`.
- To open the applicaiton, go to your lab url at port 8880 i.e `****.appsecengineer.training:8880`

## Let us perform the attack

- We see that when we open the applicaiton home page at path `/` we are greeted with the rails framework error that says that a GET parameter called `name` is expected.
- Let us provide the `name` parameter with value `hey` as `****.appsecengineer.training:8880/?name=hey` we are taken to another page where the input is reflected as is.
- let us try a basic ERB expression to check if the input is being passed in via the template engine without any sanitization?
So let us try the below

```txt
****.appsecengineer.training:8880/?name=%3C%25%3D%207%20*%207%20%25%3E%20
```

Well what is `%3C%25%3D%207%20*%207%20%25%3E%20`? It is the URL encoded form of the ERB expression `<%= 7 * 7 %>`. If there actually is a template engine and if our user input is being passed without any protection then the template injection would result in the value `49` as the above ERB expression would get evaluated dynamically via ERB template engine.

- We see that indeed `49` is being displayed which means we have successfully detected a ruby ERB template injection!

## Payloads for exploitation

### Checking for built-in functions

A good start is to test to see if built-in global functions work.  Our next payload we try is: `<%= File.open('/etc/passwd').read %>`

let us try the above payload after URL encoding it! So we try the below

```txt
****.appsecengineer.training:8880/?name=%3C%25%3D%20File.open(%27%2Fetc%2Fpasswd%27).read%20%25%3E
```

Well what do we know! We are above to read the `/etc/passwd` file!

### **Note**

>Ruby’s ERB template engine has a safe level parameter; when the safe level is set beyond zero, such as three (3), certain functions >like file operations cannot be executed from within the template binding.  If the application has a safe level of four (4), maximum >isolation is provided and only code marked trusted can be executed

---
Now that we have successfully detected and exploited ERB template injection, let us look for what went wrong?

---

## Vulnerable Code Investigation

- Let us open the `app.rb` file, we see a simple applicaiton logic

```rb
# app.rb
require 'sinatra'

get '/' do
  erb params[:name]
end

```

The above is a simple Ruby web application using the Sinatra framework.

- `get '/' do ... end:` block

This block defines a Sinatra route. In this case, it's a GET request to the root URL ("/").
The block is executed when someone accesses the root URL of the application using a web browser or another HTTP client.

- `erb params[:name]`

This line renders an ERB (Embedded Ruby) template. The template file to render is determined by the value of the `:name` parameter in the request's query string.

`params[:name]` retrieves the value of the :name parameter from the query string. For example, if the URL is / or /some_path?name=test, it will render the ERB template named `test.erb` (assuming such a template exists).

This usage of `params[:name]` without proper validation or sanitation could potentially be a security risk, as it allows an attacker to specify the template to render. It might lead to template injection vulnerabilities if user input is not properly validated.

It's crucial to validate and sanitize user input before using it to render templates to prevent potential security issues.

## The End

We are done with detcting and exploiting ERB template injection in the vulnerable application.

We have also figured out the vulnerable code.

Now let us work on securing this application in the **Defense** subject of this course!

## References

- <https://owasp.org/www-project-web-security-testing-guide/v41/4-Web_Application_Security_Testing/07-Input_Validation_Testing/18-Testing_for_Server_Side_Template_Injection>
