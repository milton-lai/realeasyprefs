**REALEasyPrefs** is a **REALbasic** module that provides support for creating and maintaining application preferences files on OS X, Linux, and Windows.  While you can use any filename you choose for your prefefrence file, by default the preference file is created in the user's hierarchy:

OS X:

> `/Users/shortname/Library/Preferences/com.companyname.product`

Linux:

> `/home/shortname/.product`

Windows:

> `C:\(depends on Windows version)\CompanyName\Product`

Setup and Use:

When preparing to use the REALEasyPrefs module, there are three constants that must be assigned if you wish to use a set of defaults aimed at the application itself.  These are all string constants within the REALEasyPrefs module:

For Mac:

`kBundleIdentifier` - the URI-style bundle identifier

> `kBundleIdentifier = "com.tolisgroup.REALEasyPrefs"`

For Linux and Windows:

`kProductName` - The name of the product.  ProductName doesn't need to match the app name.

> `kProductName = "REALEasyPrefs"`

For Windows:

`kCompanyName` - your company name to create a subfolder to store your app's information

> `kCompanyName = "TOLIS Group"`

You must change the default assigned values.  If leave them as they are, you'll get a reminder warning dialog when you run your project.

To start using the module, call `InitPrefFile()`,  If you wish to override the default names, you can pass a specific name as the argument with `InitPrefFile("MyName")`.

The set methods all start with `Set` and the get methods all start with `Get`.

To Delete a pref entry, call `DeletePref("PrefName")`

To save the prefs, call `WritePrefFile()`.  Until you call `WritePrefFile()`, your preference is only available in memory.  Therefore, you may use this module to create non-saved runtime preferences without calling `InitPrefFile()` or `WritePrefFile()`.  The overhead for `WritePrefFile()` is low enough that you should be able to call it after any change or call to a `Set` method.

Samples:

Setting a preference involves giving the preference a string name (UTF8 is supported) followed by the value to save.

> `SetPrefBoolean("My First Boolean", True)`

> `SetPrefString("History", "This is the history of REALEasyPrefs")`

> `SetPrefNumber("AnIntegerNumber", 323)`

Retrieving the value for a preference involves calling the preference by the name assigned in the previous Set call and providing a default value that will be assigned if the preference called doesn't exist or doesn't currently have a value assigned.

> `GetPrefBoolean("Non Existant Pref", False)`

That returns the assigned value for "Non Existant Pref" if it is assigned, or sets it to False if it doesn't exist or isn't defined.

**REALEasyPrefs** was originally created by _Chris Comeau_, but he appears to have gone AWOL from the REALbasic developer world.  This version has been updated by me (_Tim Jones_) for use with **REALbasic** / **REAL Studio** 2009r4 or newer.  Version 1.1 updates provided by _Melli_.