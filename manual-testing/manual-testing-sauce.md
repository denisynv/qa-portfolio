# Manual Testing: Swag Labs (saucedemo.com)

|||
|-|-|
|**Application**|Swag Labs demo shop, https://www.saucedemo.com|
|**Tester**|Denis Yanev|
|**Date**|31.10.2026|
|**Environment**|Google Chrome, Windows 11|
|**Scope**|Login, inventory sorting, cart, checkout, logout|
|**Note**|Practice site with deliberately defective users (`problem\_user`, `error\_user`, `performance\_glitch\_user`, `visual\_user`)|

## 1\. Test cases

Status values: **Pass**, **Fail**, **Open question** (specification unclear), **Not executed**.

### Login

|ID|Title|Preconditions|Steps|Expected result|Actual result|Status|Priority|Type|
|-|-|-|-|-|-|-|-|-|
|TC-LOGIN-001|Login succeeds with valid credentials|`standard\_user` exists and is active; login page is open|1. Enter a valid username<br>2. Enter the valid password<br>3. Click **Login**|The inventory page opens and the product list is displayed|As expected|Pass|High|Positive|
|TC-LOGIN-002|Login fails with a wrong password|Login page is open|1. Enter a valid username<br>2. Enter a wrong password<br>3. Click **Login**|Error: "Epic sadface: Username and password do not match any user in this service". User stays on the login page|As expected|Pass|High|Negative|
|TC-LOGIN-003|Login fails with an empty username|Login page is open|1. Leave the username empty<br>2. Enter the valid password<br>3. Click **Login**|Error: "Epic sadface: Username is required"|As expected|Pass|High|Negative|
|TC-LOGIN-004|Login fails with an empty password|Login page is open|1. Enter a valid username<br>2. Leave the password empty<br>3. Click **Login**|Error: "Epic sadface: Password is required"|As expected|Pass|High|Negative|
|TC-LOGIN-005|Login is blocked for a locked-out user|Login page is open; `locked\_out\_user` exists|1. Enter the username `locked\_out\_user`<br>2. Enter the valid password<br>3. Click **Login**|Error: "Epic sadface: Sorry, this user has been locked out." User stays on the login page|As expected|Pass|High|Negative|

### Sorting

|ID|Title|Preconditions|Steps|Expected result|Actual result|Status|Priority|Type|
|-|-|-|-|-|-|-|-|-|
|TC-SORT-001|Sort products by name A to Z|Logged in as `standard\_user`; inventory page is open|1. Open the sort dropdown<br>2. Select **Name (A to Z)**|Products are listed in ascending alphabetical order by name|As expected|Pass|Medium|Positive|
|TC-SORT-002|Sort products by name Z to A|Logged in as `standard\_user`; inventory page is open|1. Open the sort dropdown<br>2. Select **Name (Z to A)**|Products are listed in descending alphabetical order by name|As expected|Pass|Medium|Positive|
|TC-SORT-003|Sort products by price, low to high|Logged in as `standard\_user`; inventory page is open|1. Open the sort dropdown<br>2. Select **Price (low to high)**|Products are listed in ascending price order; the cheapest product is first|As expected|Pass|Medium|Positive|
|TC-SORT-004|Sort products by price, high to low|Logged in as `standard\_user`; inventory page is open|1. Open the sort dropdown<br>2. Select **Price (high to low)**|Products are listed in descending price order; the most expensive product is first|As expected|Pass|Medium|Positive|

### Cart

|ID|Title|Preconditions|Steps|Expected result|Actual result|Status|Priority|Type|
|-|-|-|-|-|-|-|-|-|
|TC-CART-001|Cart badge shows the correct item count|Logged in as `standard\_user`; cart is empty|1. Click **Add to cart** on one product<br>2. Click **Add to cart** on a second product<br>3. Click **Remove** on one product|The badge shows 1, then 2, then 1|As expected|Pass|High|Positive|
|TC-CART-002|Cart shows the correct products|Logged in as `standard\_user`; two products were added|1. Click the cart icon<br>2. Compare the cart with the products you added|Cart lists exactly the added products with the same names and prices|As expected|Pass|High|Positive|
|TC-CART-003|Remove a product in the cart|Logged in as `standard\_user`; two products are in the cart; cart page is open|1. Click **Remove** next to one product|The product disappears from the cart and the badge decreases by 1|As expected|Pass|High|Positive|

### Checkout

|ID|Title|Preconditions|Steps|Expected result|Actual result|Status|Priority|Type|
|-|-|-|-|-|-|-|-|-|
|TC-CHK-001|Checkout fails with all fields empty|Logged in as `standard\_user`; at least one product in the cart; checkout step one is open|1. Leave First Name, Last Name and Zip/Postal Code empty<br>2. Click **Continue**|Error: "Error: First Name is required". User stays on step one|As expected|Pass|High|Negative|
|TC-CHK-002|Checkout fails with the postal code missing|Same as TC-CHK-001|1. Enter a first name<br>2. Enter a last name<br>3. Leave Zip/Postal Code empty<br>4. Click **Continue**|Error: "Error: Postal Code is required". User stays on step one|As expected|Pass|High|Negative|
|TC-CHK-003|Complete a valid order|Same as TC-CHK-001|1. Enter first name, last name and postal code<br>2. Click **Continue**<br>3. Review the overview<br>4. Click **Finish**|The order confirmation page is displayed|As expected|Pass|High|Positive|
|TC-CHK-004|Cancel on checkout step one|Same as TC-CHK-001; checkout step one is open|1. Click **Cancel**|User returns to the cart page *(expected behaviour assumed, confirm with specification)*|\[fill in]|Not executed|Medium|Positive|
|TC-CHK-005|Cancel on the overview step (step two)|Valid name and postal code entered; overview page is open|1. Click **Cancel**|Not defined in a specification|User returns to the products page, not the cart|Open question|Low|Negative|

### Logout

|ID|Title|Preconditions|Steps|Expected result|Actual result|Status|Priority|Type|
|-|-|-|-|-|-|-|-|-|
|TC-LOGOUT-001|Logout ends the session|Logged in as `standard\_user`|1. Open the menu (top left)<br>2. Click **Logout**|User is logged out and the login page is displayed|As expected|Pass|High|Positive|

## 2\. Exploratory observations (other users)

Not scripted. Same shop, different user types. These users contain defects by design.

|User|What I observed|Bug candidate|Severity idea|
|-|-|-|-|
|`problem\_user`|All product images are wrong; products cannot be removed from the product page, only from the cart; on checkout step one the last name cannot be entered, so the purchase cannot be completed|Yes (3 separate issues)|High (checkout is blocked)|
|`performance\_glitch\_user`|Login took about 10 seconds|Yes|Medium|
|`error\_user`|The last name field has the same problem; checkout continues to the finish page, but clicking **Finish** does nothing|Yes|High (order cannot be completed)|
|`visual\_user`|The backpack image is wrong; the cart button is placed oddly; on the cart page the checkout button is also misplaced|Yes|Low to Medium (layout)|

## 3\. Open questions

|#|Question|Why it matters|
|-|-|-|
|1|Where should **Cancel** lead on the overview step (cart or products page)?|No specification, so it cannot be called a bug (TC-CHK-005)|



