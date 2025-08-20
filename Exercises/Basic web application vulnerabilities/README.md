# Basic Web Application Vulnerabilities

Welcome to this exercise! Here, you'll explore and exploit common vulnerabilities found in basic web applications.

---

## Exercise Description

Your goal is to identify and exploit at least one vulnerability in the provided web application. Typical issues may include SQL injection, cross-site scripting (XSS), or insecure authentication.

---

<button id="hint-btn" onclick="document.getElementById('hint').style.display='block';">Show Hint</button>
<div id="hint" style="display:none; margin-top:10px; border-left:3px solid #007bff; padding-left:10px;">
**Hint:** Try submitting unexpected input in form fields and observe the application's response.
</div>

<br>

<button id="solution-btn" onclick="document.getElementById('solution').style.display='block';">Show Solution</button>
<div id="solution" style="display:none; margin-top:10px; border-left:3px solid #28a745; padding-left:10px;">
**Solution:** One possible vulnerability is SQL injection. Try entering `' OR
</div>