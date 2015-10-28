#tag Module
Module REALEasyPrefs
	#tag Method, Flags = &h0
		Sub DeletePref(fieldName as string)
		  Dim n as integer
		  
		  for n=0 to UBound(prefNames)
		    if prefNames(n)=fieldName then
		      prefNames.remove n
		      prefItems.remove n
		    end if
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPrefBoolean(fieldName as string, default as boolean) As Boolean
		  Dim strBoolean as string
		  
		  strBoolean="false"
		  if default then
		    strBoolean="true"
		  end if
		  
		  strBoolean=GetPrefString(fieldName,strBoolean)
		  
		  if strBoolean="true" then
		    return true
		  else
		    return false
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPrefColor(fieldName as string, default as Color) As Color
		  Dim colString as string
		  
		  colString=Str(default.red)+","+Str(default.green)+","+Str(default.blue)
		  colString=GetPrefString(fieldName,colString)
		  return RGB(Val(NthField(colString,",",1)),Val(NthField(colString,",",2)),Val(NthField(colString,",",3)))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPrefDouble(fieldName as string, default as double) As Double
		  return Val(GetPrefString(fieldName,Str(default)))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPrefFolderItem(fieldName as string, default as FolderItem) As FolderItem
		  Dim strFolderItem as string
		  
		  if default=nil then
		    strFolderItem=""
		  else
		    strFolderItem=default.AbsolutePath
		  end if
		  
		  strFolderItem=GetPrefString(fieldName,strFolderItem)
		  if strFolderItem="" then
		    return nil
		  else
		    return GetFolderItem(strFolderItem)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetPrefListBox(fieldName as string, default as ListBox)
		  Dim row,col as integer
		  Dim trows,tcols as integer
		  
		  trows=GetPrefNumber(fieldName+" NRows",default.ListCount)
		  tcols=GetPrefNumber(fieldName+" NCols",default.ColumnCount)
		  
		  default.ColumnCount=tcols
		  default.ColumnWidths=GetPrefString(fieldName+" CWidths",default.ColumnWidths)
		  
		  
		  for row=0 to trows-1
		    default.AddRow ""
		    for col=0 to tcols-1
		      default.Cell(row,col)=GetPrefString(fieldName+" Cell("+Str(row)+","+Str(col)+")","")
		    next
		  next
		  
		  for row=0 to trows-1
		    if GetPrefBoolean(fieldName+" Sel "+Str(row),false) then
		      default.Selected(row)=true
		    end if
		  next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPrefNumber(fieldName as string, default as integer) As Integer
		  return Val(GetPrefString(fieldName,Str(default)))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetPrefPopupMenu(fieldName as string, default as PopupMenu)
		  Dim n,total as integer
		  
		  //Items
		  total=GetPrefNumber(fieldName+" Items",0)
		  if total <> 0 Then
		    default.DeleteAllRows
		    for n=0 to total-1
		      default.AddRow GetPrefString(fieldName+" Item "+Str(n),"")
		    next
		  End If
		  
		  //Selection
		  default.ListIndex=GetPrefNumber(fieldName+" Selection", default.ListIndex)
		  default.Refresh
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPrefString(fieldName as string, default as string) As String
		  Dim n as integer
		  
		  for n=0 to UBound(prefNames)
		    if prefNames(n)=fieldName then
		      return prefItems(n)
		    end if
		  next
		  
		  return default
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetPrefWindow(fieldName as string, default as Window)
		  Dim winStr as string
		  
		  winStr=Str(default.left)+","+Str(default.top)+","+Str(default.width)+","+Str(default.height)
		  winStr=GetPrefString(fieldName,winStr)
		  
		  default.left=Val(NthField(winStr,",",1))
		  default.top=Val(NthField(winStr,",",2))
		  default.width=Val(NthField(winStr,",",3))
		  default.height=Val(NthField(winStr,",",4))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InitPrefFile(prefName as string = "")
		  // Trap default constant values and warn developer
		  If kProductName = "New Product Name" Or _
		    kCompanyName = "New Company Name" Or _
		    kBundleIdentifier = "com.NewCompany.NewProduct" Then
		    MsgBox "Developer Warning" + EndOfLine + EndOfLine + _
		    "Required constants not defined" + EndOfLine + EndOfLine + _
		    "You must assign proper values to the kCompanyName, kProductName, and kBundleIdentifier constants in the REALEasyPrefs module"
		  End If
		  
		  #if TargetMacOS then
		    dim macbundleidentifier as String = kBundleIdentifier
		    InitPrefFolderFileMac(macbundleidentifier)
		  #else
		    InitPrefFolderFileWinLinux(kProductName, kCompanyName)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InitPrefFolderFileMac(bundleIdentifierName as string = "")
		  #if TargetMacOS then
		    
		    Dim aOut as TextOutputStream
		    Dim aIn as TextInputStream
		    Dim TmpStr As String
		    
		    Redim prefNames(-1)
		    Redim prefItems(-1)
		    
		    // check, if BundleIdentifier is regularly set
		    if bundleIdentifierName = "" then
		      if kBundleIdentifier <> "" then
		        BundleIdentifierName = kBundleIdentifier
		      end if
		    end if
		    
		    prefFile = SpecialFolder.Preferences.Child(BundleIdentifierName)
		    
		    if not prefFile.Exists then
		      aOut=TextOutputStream.Create(prefFile)
		      prefFile.Permissions = &o666
		    else
		      aIn=TextInputStream.Open(prefFile)
		      while not aIn.EOF
		        tmpStr = aIn.ReadLine
		        //updated so we can have "=" in the value pair (base64encoding generates = signs)
		        dim tmpStrArray() as string = tmpStr.Split("")
		        dim delimIndex as integer = tmpStrArray.IndexOf("=")
		        if delimIndex > -1 then
		          prefNames.append(TmpStr.Left(delimIndex))
		          prefItems.append(TmpStr.Right(tmpStrArray.Ubound - delimIndex))
		        end
		      wend
		    end if
		  #else
		    MsgBox "Not running under OS X - please contact the developer!"
		    quit
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InitPrefFolderFileWinLinux(prefName as string = "", prefFolderName as string = "")
		  #if not TargetMacOS then
		    
		    Dim aOut as TextOutputStream
		    Dim aIn as TextInputStream
		    Dim TmpStr As String
		    
		    Redim prefNames(-1)
		    Redim prefItems(-1)
		    
		    // check, if CompanyName is regularly set (WIN)
		    // check, if ProductName is regularly set (WIN and Linux)
		    
		    #if TargetWin32 then
		      if prefFolderName = "" then
		        if kCompanyName <>"" then
		          prefFolderName = kCompanyName
		        end if
		      end if
		      if prefName = "" then
		        if kProductName <> "" then
		          prefName = kProductName
		        end if
		      end if
		    #else
		      if prefName = "" then
		        if kProductName <> "" then
		          prefName = kProductName
		        end if
		      end
		    #endif
		    
		    //check, if folder is set and create the file in the folder
		    #if TargetWin32 then
		      If Not SpecialFolder.Preferences.Child(prefFolderName).Exists Then
		        SpecialFolder.Preferences.Child(prefFolderName).CreateAsFolder
		        if Not SpecialFolder.Preferences.Child(prefFolderName).Exists then
		          MsgBox "Something big wrong in the Application."+EndOfLine+"Please contact the Developer!"
		          quit
		        end if
		      End If
		      prefFile = SpecialFolder.Preferences.Child(prefFolderName).Child(prefName + ".ini")
		    #else // Linux and the rest
		      prefFile = SpecialFolder.UserHome.Child("." + prefName)
		    #endif
		    
		    if not prefFile.Exists then
		      aOut=TextOutputStream.Create(prefFile)
		      prefFile.Permissions = &o666
		    else
		      aIn=TextInputStream.Open(prefFile)
		      while not aIn.EOF
		        tmpStr = aIn.ReadLine
		        //updated so we can have "=" in the value pair (base64encoding generates = signs)
		        dim tmpStrArray() as string = tmpStr.Split("")
		        dim delimIndex as integer = tmpStrArray.IndexOf("=")
		        if delimIndex > -1 then
		          prefNames.append(TmpStr.Left(delimIndex))
		          prefItems.append(TmpStr.Right(tmpStrArray.Ubound - delimIndex))
		        end
		      wend
		    end if
		  #else
		    MsgBox "is a Mac - wrong function called - please contact the developer!"
		    quit
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefBoolean(fieldName as string, fieldValue as Boolean)
		  Dim strBoolean as string
		  
		  strBoolean="false"
		  if fieldValue then
		    strBoolean="true"
		  end if
		  
		  SetPrefString(fieldName,strBoolean)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefColor(fieldName as string, fieldValue as Color)
		  Dim colString as string
		  
		  colString=Str(fieldValue.red)+","+Str(fieldValue.green)+","+Str(fieldValue.blue)
		  SetPrefString(fieldName,colString)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefDouble(fieldName as string, fieldValue as double)
		  SetPrefString(fieldName,Str(fieldValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefFolderItem(fieldName as string, fieldValue as FolderItem)
		  if fieldValue=nil then
		    DeletePref(fieldName)
		    return
		  end if
		  SetPrefString(fieldName,fieldValue.AbsolutePath)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefListBox(fieldName as string, fieldValue as ListBox)
		  Dim row,col as integer
		  Dim trows,tcols as integer
		  
		  //------Remove Old
		  trows=GetPrefNumber(fieldName+" NRows",0)
		  tcols=GetPrefNumber(fieldName+" NCols",0)
		  
		  DeletePref(fieldName+" NRows")
		  DeletePref(fieldName+" NCols")
		  DeletePref(fieldName+" CWidths")
		  
		  for row=0 to trows-1
		    for col=0 to tcols-1
		      DeletePref(fieldName+" Cell("+Str(row)+","+Str(col)+")")
		    next
		  next
		  
		  for row=0 to trows-1
		    DeletePref(fieldName+" Sel "+Str(row))
		  next
		  
		  
		  //------Add New
		  
		  'Num Rows
		  SetPrefNumber(fieldName+" NRows",fieldValue.ListCount)
		  'NumCols
		  SetPrefNumber(fieldName+" NCols",fieldValue.ColumnCount)
		  'ColWidth
		  SetPrefString(fieldName+" CWidths",fieldValue.ColumnWidths)
		  'cells
		  for row=0 to fieldValue.ListCount-1
		    for col=0 to fieldValue.ColumnCount-1
		      SetPrefString(fieldName+" Cell("+Str(row)+","+Str(col)+")",fieldValue.Cell(row,col))
		    next
		  next
		  'selections
		  for row=0 to fieldValue.ListCount-1
		    if fieldValue.Selected(row) then
		      SetPrefBoolean(fieldName+" Sel "+Str(row),true)
		    end if
		  next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefNumber(fieldName as string, fieldValue as integer)
		  SetPrefString(fieldName,Str(fieldValue))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefPopupMenu(fieldName as string, fieldValue as PopupMenu)
		  Dim n,total as integer
		  
		  //----Remove
		  // Old Items
		  total=GetPrefNumber(fieldName+" Items",0)
		  DeletePref(fieldName+" Items")
		  for n=0 to total-1
		    DeletePref(fieldName+" Item "+Str(n))
		  next
		  // Selection
		  DeletePref(fieldName+" Selection")
		  
		  
		  //-----Add New
		  // Items
		  SetPrefNumber(fieldName+" Items",fieldValue.ListCount)
		  for n=0 to fieldValue.ListCount-1
		    SetPrefString(fieldName+" Item "+Str(n),fieldValue.List(n))
		  next
		  // Selection
		  SetPrefNumber(fieldName+" Selection",fieldValue.ListIndex)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefString(fieldName as string, fieldValue as string)
		  Dim n as integer
		  
		  for n=0 to UBound(prefNames)
		    if prefNames(n)=fieldName then
		      prefItems(n)=fieldValue
		      return
		    end if
		  next
		  
		  prefNames.append fieldName
		  prefItems.append fieldValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPrefWindow(fieldName as string, fieldValue as Window)
		  Dim winStr as String
		  
		  if fieldValue=nil then
		    DeletePref(fieldName)
		    return
		  end if
		  
		  winStr=Str(fieldValue.left)+","+Str(fieldValue.top)+","+Str(fieldValue.width)+","+Str(fieldValue.height)
		  SetPrefString(fieldName,winStr)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WritePrefFile()
		  Dim aOut as TextOutputStream
		  Dim n as integer
		  
		  prefFile.Delete
		  aOut=TextOutputStream.Create(prefFile)
		  for n=0 to UBound(prefNames)
		    aOut.Write prefNames(n) + "=" + prefItems(n) + EndOfLine.Unix
		  next
		  prefFile.MacType="pref"
		End Sub
	#tag EndMethod


	#tag Note, Name = Credits
		Originally by Chris Cormeau.
		
		This version has been modified and updated for the new REAL Studio IDE and Frameworks by Tim Jones.  New InitPrefFile code from Melli
		
		Code is hosted at http://code.google.com/p/realeasyprefs/.
		
		tolistim@me.com
	#tag EndNote

	#tag Note, Name = New_Init_Code_From_Melli
		// Place in
		#if TargetMacOS then
		dim macbundleidentifier as String =_
		"com."+ kCompanyName+"."+ kProductName
		InitPrefFolderFileMac(macbundleidentifier)
		#else
		InitPrefFolderFileWinLinux(kProductName, kCompanyName)
		// start for Linux or other than WIN32
		// InitPrefFolderFileWinLinux("testfile")
		#endif
		
		sub InitPrefFolderFileMac(bundleIdentifierName as string =""){
		#if TargetMacOS then
		
		Dim aOut as TextOutputStream
		Dim aIn as TextInputStream
		Dim TmpStr As String
		
		Redim prefNames(-1)
		Redim prefItems(-1)
		
		// check, if BundleIdentifier is regularly set
		if bundleIdentifierName = "" then
		if kBundleIdentifier <> "" then
		BundleIdentifierName = kBundleIdentifier
		end if
		end if
		
		//set folder, create if not exists
		if not SpecialFolder.Preferences.Child(BundleIdentifierName) then
		SpecialFolder.Preferences.Child(BundleIdentifierName).CreateAsFolder
		end if
		prefFile = SpecialFolder.Preferences.Child(BundleIdentifierName)
		
		
		if not prefFile.Exists then
		aOut=TextOutputStream.Create(prefFile)
		prefFile.Permissions = &o666
		else
		aIn=TextInputStream.Open(prefFile)
		while not aIn.EOF
		tmpStr = aIn.ReadLine
		        //updated so we can have "=" in the value pair (base64encoding generates = signs)
		        dim tmpStrArray() as string = tmpStr.Split("")
		        dim delimIndex as integer = tmpStrArray.IndexOf("=")
		        if delimIndex > -1 then
		          prefNames.append(TmpStr.Left(delimIndex))
		          prefItems.append(TmpStr.Right(tmpStrArray.Ubound - delimIndex))
		        end
		wend
		end if
		#else
		MsgBox "Not running under OS X - please contact the developer!"
		quit
		#endif
		}
		
		sub InitPrefFolderFileWinLinux(prefName as string = "", prefFolderName as string =""){
		
		#if not TargetMacOS then
		
		Dim aOut as TextOutputStream
		Dim aIn as TextInputStream
		Dim TmpStr As String
		
		Redim prefNames(-1)
		Redim prefItems(-1)
		
		// check, if CompanyName is regularly set (WIN)
		// check, if ProductName is regularly set (WIN and Linux)
		
		#if TargetWin32 then
		if prefFolderName = "" then
		if kCompanyName <>"" then
		prefFolderName = kCompanyName
		end if
		end if
		if prefName = "" then
		if kProductName <> "" then
		prefName = kProductName
		end if
		end if
		#else
		if prefName = "" then
		if kProductName <> "" then
		prefName = kProductName
		end if
		end
		#endif
		
		//check, if folder is set and create the file in the folder
		#if TargetWin32 then
		If Not SpecialFolder.Preferences.Child(prefFolderName).Exists Then
		SpecialFolder.Preferences.Child(prefFolderName).CreateAsFolder
		if Not SpecialFolder.Preferences.Child(prefFolderName).Exists then
		MsgBox "Something big wrong in the Application."+EndOfLine+"Please contact the Developer!"
		quit
		end if
		End If
		prefFile = SpecialFolder.Preferences.Child(prefFolderName).Child(prefName + ".ini")
		#else // Linux and the rest
		prefFile = SpecialFolder.UserHome.Child("." + prefName)
		#endif
		
		if not prefFile.Exists then
		aOut=TextOutputStream.Create(prefFile)
		prefFile.Permissions = &o666
		else
		aIn=TextInputStream.Open(prefFile)
		while not aIn.EOF
		tmpStr = aIn.ReadLine
		        //updated so we can have "=" in the value pair (base64encoding generates = signs)
		        dim tmpStrArray() as string = tmpStr.Split("")
		        dim delimIndex as integer = tmpStrArray.IndexOf("=")
		        if delimIndex > -1 then
		          prefNames.append(TmpStr.Left(delimIndex))
		          prefItems.append(TmpStr.Right(tmpStrArray.Ubound - delimIndex))
		        end
		wend
		end if
		#else
		MsgBox "is a Mac - wrong function called - please contact the developer!"
		quit
		#endif
		End Sub
	#tag EndNote

	#tag Note, Name = Original_InitPrefFile
		
		Dim aOut as TextOutputStream
		Dim aIn as TextInputStream
		Dim TmpStr As String
		
		Redim prefNames(-1)
		Redim prefItems(-1)
		
		If prefName = "" Then
		#if TargetMacOS
		prefFile = SpecialFolder.Preferences.Child(BundleIdentifier)
		#elseif TargetWin32
		If Not SpecialFolder.Preferences.Child(CompanyName).Exists Then
		SpecialFolder.Preferences.Child(CompanyName).CreateAsFolder
		// Should add check to make sure the folder was created
		End If
		prefFile = SpecialFolder.Preferences.Child(CompanyName).Child(ProductName + ".ini")
		#else // Linux
		prefFile = SpecialFolder.UserHome.Child("." + ProductName)
		#endif
		Else
		prefFile = SpecialFolder.Preferences.Child(prefName)
		End If
		
		if not prefFile.Exists then
		aOut=TextOutputStream.Create(prefFile)
		prefFile.Permissions = &o666
		else
		aIn=TextInputStream.Open(prefFile)
		while not aIn.EOF
		tmpStr = aIn.ReadLine
		        //updated so we can have "=" in the value pair (base64encoding generates = signs)
		        dim tmpStrArray() as string = tmpStr.Split("")
		        dim delimIndex as integer = tmpStrArray.IndexOf("=")
		        if delimIndex > -1 then
		          prefNames.append(TmpStr.Left(delimIndex))
		          prefItems.append(TmpStr.Right(tmpStrArray.Ubound - delimIndex))
		        end
		wend
		end if
	#tag EndNote

	#tag Note, Name = Setup_And_Use
		When preparing to use the REALEasyPrefs module, there are three protected
		properties that must be assigned if you wish to use a set of defaults
		aimed at the application itself.  These are all string properties within
		the REALEasyPrefs module:
		
		For Mac:
		BundleIdentifier - the URI-style bundle identifier
		  BundleIdentifier = com.tolisgroup.REAEasyPfefs
		
		For Linux and Windows:
		ProductName - The name of the product.  ProductName doesn't need to match the app name.
		  ProductName = "REALEasyPrefs"
		
		For Windows:
		CompanyName - your company name to create a subfolder to store your app's information
		  CompanyName = "TOLIS Group"
		
		For now, you must set these up and if they are missing, you'll get some "creative" defaults.
		
		To start using the module, call InitPrefFile(),  If you wish to override the default
		names, you can pass a specific name as the argument with InitPrefFile("MyName").
		
		The set methods all start with Set and the get methods all Start with Get.
		
		To Delete a pref entry, call DeletePref("PrefName")
		
		To save the prefs, call WritePrefFile().  Until you call WritePrefFile(), your preference
		is only available in memory.  Therrefore, you may use this module to create non-saved
		runtime preferences without calling InitPrefFile() or WritePrefFile().  The overhead for
		WritePrefFile() is low enough that you should be able to call it after any change or 
		call to a Set method.
		
		Samples:
		
		Setting a preference involves giving the preference a string name (UTF8 is supported) followed
		by the value to save.
		
		  SetPrefBoolean("My First Boolean", True)
		  SetPrefString("History", "This is the history of REALEasyPrefs")
		  SetPrefNumber("AnIntegerNumber", 323)
		
		Retrieving the value for a preference involves calling the preference by the name assigned
		in the previous Set call and providing a default value that will be assigned if the preference
		called doesn't exist or doesn't currently have a vvalue assigned.
		
		  GetPrefBoolean("Non Existant Pref", False)
		  
		That returns the assigned value for "Non Existant Pref" is it is assigned, or sets it to
		False if it doesn't exist or isn't defined.
	#tag EndNote


	#tag Property, Flags = &h1
		Protected prefFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected prefItems(-1) As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected prefNames(-1) As string
	#tag EndProperty


	#tag Constant, Name = kBundleIdentifier, Type = String, Dynamic = False, Default = \"com.NewCompany.NewProduct", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCompanyName, Type = String, Dynamic = False, Default = \"New Company Name", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kProductName, Type = String, Dynamic = False, Default = \"New Product Name", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kREPVersion, Type = String, Dynamic = False, Default = \"1.1", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
