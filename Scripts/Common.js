
    var browserName = navigator.appName.toUpperCase(); //Get browser name
        
     function getScrollBottom(p_oElem)
    {
        return p_oElem.scrollHeight - p_oElem.scrollTop - p_oElem.clientHeight;
    }
//****************

/* ************** */


    function CheckLength(txt, len, e)
    {
        if (document.getElementById(txt).value.length >= len)
        {
            StopEvent(e);
        }
        return false;
    }
    
    function RemoveChar(txt, len)
    {
        if (document.getElementById(txt).value.length >= len)
        {
            document.getElementById(txt).value=document.getElementById(txt).value.substring(0,len);
        }
        return false;
    }

    function checkSpecialChar()
    {
      var iChars = "!@#$%^&*()+=-[]\\\';,./{}|\":<>?";

      for (var i = 0; i < document.formname.fieldname.value.length; i++) {
  	    if (iChars.indexOf(document.formname.fieldname.value.charAt(i)) != -1) {
  	    alert ("Your username has special characters. \nThese are not allowed.\n Please remove them and try again.");
  	    return false;
  	    }
      }
    }
    
    function IgnoreSpeicalChar()
    {
        var x=event.keyCode;
        alert(x);
        if (x==33 || x==34 || x==35 || x==36 || x==37 || x==38|| x==39 || x==40 || x==41|| x==42 || x==43 || x==44 || x==45  || x==60 || x==61 || x==62 || x==63 || x==91 || x==93 || x==94 || x==96 || x==123 || x==124 || x==125 || x==126)
            {
                event.keyCode="";
                return;
            }       
    }

    /* Allow only numeric values */
    function checkAllNumeric(e)
    {
        var iChars = "0123456789";
        for (var i = 0; i < e.value.length; i++)
        {
  	        if (iChars.indexOf(e.value.charAt(i)) == -1) 
  	        {
  	            alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
	            e.focus();
  	            return false;
  	        }
        }
    } 
    
    /* Allow only integer (negative and numeric value) and one digit values -- added by Janki 0n 03Sep08*/
    function checkOnlyInteger(e)
    {      
        if(e.value != "")
        {   
            var iChars = "0123456789";
            var iNegative = "-";       
            if(e.value.length == 1)
            {           
                if(iChars.indexOf(e.value.charAt(0)) == -1)
                {
                      alert("Only One digit integers allowed.\n Please remove others and try again.");
                      e.focus();
                      return false;
                }
            }
            else
            {
                if(e.value.length == 2)
                {               
                     if(iChars.indexOf(e.value.charAt(1)) == -1 || iNegative.indexOf(e.value.charAt(0)) == -1)
                    {
                    
                          alert("Only One digit integers allowed.\n Please remove others and try again.");
                          e.focus();
                          return false;
                    }
                }
                else
                {
                     if(e.value.length > 2)
                        {               
                              alert("Only One digit integers allowed.\n Please remove others and try again.");
                              e.focus();
                              return false;               
                        }
                }
            }
        }

    }
    
    //////////////////////////////// Script for checking only numbers (0-9) /////////////////////////////
    function checkOnlyNumbers(e)
    {
        var iChars = "1234567890";
        for (var i = 0; i < e.value.length; i++) 
        {
            if (iChars.indexOf(e.value.charAt(i)) == -1) 
            {
                alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
                e.focus();
                return false;
            }
        }
    }
    /* Allow only numeric values */
    function AllowOnlyNumbers(e)
    {
        var x = ReturnKeyCodeOnKeyPress(e)    
        
        //alert(x)
        
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        if ((x<48 || x>57) && x!=0 && x!=8 && x!=9 && x!=46)
           /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)           
        }
    }
     /* Allow only numeric values With Percentage. Use for Advance Search Control */
    function AllowOnlyNumbersWithPercentage(e)
    {
        var x = ReturnKeyCodeOnKeyPress(e)    
        //alert(x)
        
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        if ((x<48 || x>57) && x!=0 && x!=8 && x!=9 && x!=46 && x!=37)
           /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)           
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////// Script for checking only numbers (1-9) ////////////////////////////////
    function checkOnlyNumeric(e)
    {
        var iChars = "0123456789";

        for (var i = 0; i < e.value.length; i++) 
        {
            if (iChars.indexOf(e.value.charAt(i)) == -1) 
            {
                alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
                e.focus();
                return false;
            }
        }
    }
    /* Allow only numeric values */
    function AllowOnlyNumeric(e)
    {
        var x = ReturnKeyCodeOnKeyPress(e)
        /*alert(x);*/
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        if ((x<48 || x>57) && x!=0 && x!=8 && x!=9)
           /* 48 to 58 for 0 to 9, 8 for back space, */
         {
            StopEvent(e)    
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /////////////////////////// Script for checking only Alphabets (A-Z & a-z) //////////////////////////////
    /* Allow only Alphabetic values */
    function checkAllAlphabets(e)
    {
        var iChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        for (var i = 0; i < e.value.length; i++) 
        {
  	        if (iChars.indexOf(e.value.charAt(i)) == -1) 
  	        {
  	            alert ("Numeric values not allowed.\n Please remove them and try again.");
	            e.focus();
  	            return false;
  	        }
        }
    }
    /* Allow only Alphabetic values */
    function AllowOnlyAlphabets(e)
    {    
        var x = ReturnKeyCodeOnKeyPress(e)
        /*alert(x);*/        
        if ((x<65 || x>90) && (x<97 || x>122) && x!=0 && x!=8 && x!=9)
        /* 65 to 90 a -z, 97 to 122 A-Z, 8 for back space */
        {
            StopEvent(e)  
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////// Script for checking Numeric with Decimal ([0-9] & [.]) /////////////////////////
    /* Allow numeric values With Decimal*/
    function checkNumericWithDecimal(e)
    {
        var iChars = "0123456789.";
        for (var i = 0; i < e.value.length; i++) 
        {
  	        if (iChars.indexOf(e.value.charAt(i)) == -1) 
  	        {
  	            alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
  	            e.focus();
          	    return false;
  	        }
        }
    }
    /* Allow  numeric values With Decimal */
    function AllowNumbersWithDecimal(e)
    {
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/                
        var x = ReturnKeyCodeOnKeyPress(e)                     
        if ((x<48 || x>57) && x!=0 && x!=46 && x!=8 && x!=9)
        /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)               
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////// Script for checking Numeric with Colon ([0-9] & [:]) //////////////////////////
    /* Allow numeric values With colon*/
    function checkNumericWithColon(e)
    {
        var iChars = "0123456789:";
        for (var i = 0; i < e.value.length; i++) 
        {
  	        if (iChars.indexOf(e.value.charAt(i)) == -1) 
  	        {
  	            alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
  	            e.focus();
  	            return false;
  	        }
        }
    }
    /* Allow  numeric values With Colon */
    function AllowNumbersWithColon(e)
    {
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/                
        var x = ReturnKeyCodeOnKeyPress(e)                            
        if ((x<48 || x>57) && x!=0 && x!=58 && x!=8 && x!=9)
        /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)                       
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////// Script for checking Numeric with Symbols ([0-9] & [.+-*/()]) ///////////////////////
    /* Allow numeric values With Decimal*/
    function checkNumericWithSymbol(e)
    {
        var iChars = "0123456789.+-*/() ";
        for (var i = 0; i < e.value.length; i++) 
        {
  	        if (iChars.indexOf(e.value.charAt(i)) == -1) 
  	        {
  	            alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
  	            e.focus();
  	            return false;  	            
  	        }
        }
    }    
    /* Allow  numeric values With Decimal */
    function AllowNumbersWithSymbol(e)
    {
        var x = ReturnKeyCodeOnKeyPress(e)               
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        if ((x<48 || x>57) && x!=40 && x!=41 && x!=42 && x!=43 && x!=45 && x!=46 && x!=47 && x!=32 && x!=0 && x!=8 && x!=9 )
           /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)          
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////// Script for checking Numeric with Alphabets ([0-9] & [A-Z,a-z]) ///////////////////         
    /* Allow numeric and alphabets */
    function checkAlphaNumeric(e)
    {
        var iChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        for (var i = 0; i < e.value.length; i++) 
        {
  	        if (iChars.indexOf(e.value.charAt(i)) == -1) 
  	        {
  	            alert ("Symbols not allowed.\n Please remove them and try again.");
  	            e.focus();
  	            return false;
  	        }
        }
    }
    function AllowAlphaNumeric(e)
    {
        var x = ReturnKeyCodeOnKeyPress(e)                            
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        if ((x<48 || x>57) && (x<65 || x>90) && (x<97 || x>122) && x!=0  && x!=8 && x!=9)
        /* 48 to 58 for 0 to 9, 65 to 90 a -z, 97 to 122 A-Z, 8 for back space, */
        {
            StopEvent(e)       
        } 
    }  
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////// Script for checking Numeric with Decimal and Minus ([0-9] & [.,-]) /////////////////
    function checkNumericAndDotAndMinus(e)
    {
      var iChars = "0123456789.-";

      for (var i = 0; i < e.value.length; i++) {
  	    if (iChars.indexOf(e.value.charAt(i)) == -1) {
  	    alert ("Alphabetic characters not allowed.\n Please remove them and try again.");
  	    e.focus();
  	    return false;
  	    }
      }
    }
    function AllowNumbersAndDotAndMinus(e)
    {
        var x = ReturnKeyCodeOnKeyPress(e)                
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        /* [40=(] [41=)][42=*][43=+][45=-][47=/][32=" "][0=nothing] */
        if ((x<48 || x>57) && x!=45 && x!=46 && x!=0 )
        /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)       
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////   
   
    ///////////////////////// Script for checking Numeric with Decimal ([0-9] & [.]) ////////////////////////
    /* Allow  numeric values With Decimal */
    function AllowNumbersAndDot(e)
    {        
        var x = ReturnKeyCodeOnKeyPress(e)                                    
         
        /*if (x!=48 && x!=49 && x!=50 && x!=51 && x!=52 && x!=53 && x!=54 && x!=55 && x!=56 && x!=57 && x!=8)*/
        /* [40=(] [41=)][42=*][43=+][45=-][47=/][32=" "][0=nothing] */
        if ((x<48 || x>57) && x!=46 && x!=0 && x!=8 && x!=9)
        /* 48 to 58 for 0 to 9, 8 for back space, */
        {
            StopEvent(e)               
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function CheckValue(textBox)
    {
        if (textBox != null)
        {
            var str = textBox.value.split(".").length;
            var Check = new Array;
            if (str > 2)
            {
                alert("Value is incorrect.");
                textBox.focus();
               return false;
            }
            Check = textBox.value.split("-");
            var str1  = textBox.value.split("-").length;
            if (str1 > 2)
            {
                alert("Value is incorrect.");
                textBox.focus();   
                return false;
            }
            if (Check[0] != "")
            {
                if (str1 > 1)
                {
                    alert("Value is incorrect.");
                    textBox.focus();   
                   return false;
                }
            }
            else
            {
                if (Check[1] == "")
                {
                    alert("Value is incorrect.");
                    textBox.focus();   
                   return false;
                }
            }
        }
        return true;
    }
   
 
    var cnt=-1,txtName,hdnName,hdnCondition,divHelper,hCode,wCode,wName,iframe,idGlbl;    
    var singleQuotePattern = new RegExp("\\\\'","g")//\\'/g;
    var nbspPattern = new RegExp(String.fromCharCode(160), "g");
    
    function funKeyDownPopup(e,me,tblName,priField,secField,dispRows,uniqId,distFld,str1,str2) {    
    
        if (me!='')
            idGlbl=me.id;     
        txtName = document.getElementById(me.id.replace('txtCode','txtName'));                 
        hdnName = document.getElementById(me.id.replace('txtCode','hdnName'));                 
        hdnCondition  = document.getElementById(me.id.replace('txtCode','hdnCond')); 
         iframe = document.getElementById('iframetop');
        divHelper = document.getElementById(me.id.replace('txtCode','helper'));  
       
        // Decide which Browser is used. 
        x = ReturnBrowserKeycode(e);
        
        if (x==9) // When TAB is Pressed
        {     //******** Use this code to display single value in div 
//////            if (divHelper.style.display =="")
//////            {
//////                var rowcnt = divHelper.getElementsByTagName("table")[0].rows
//////                if (rowcnt.length == 2)
//////                {
//////                    if (rowcnt[0].id.toUpperCase() != 'LNKNODATA' && rowcnt[1].id.toUpperCase() == 'LNKALL')
//////                    {
//////                        me.value = rowcnt[0].childNodes[0].innerHTML.replace(/&nbsp;/g,' ');
//////                    }
//////                }
//////            }
            
            if (secField!="")
            {
                if (txtName  != null)
                {  
                    SetData(me.value,tblName,priField,secField,dispRows,hdnCondition.value,uniqId,distFld)    
                }
            }
            
            hidePopup();   
                                
        }    
            
        else if (x == 13 || event.altKey) // When Enter key
        {
            ////deugger
            if (secField!="")
            {
                if (txtName  != null)
                {
                    SetData(me.value,tblName,priField,secField,dispRows,hdnCondition.value,uniqId,distFld)        
                }
            }
           
            hidePopup();
            
            if(window.event)
                e.returnValue=false;    
           else
                e.preventDefault();                         
        }
         if (divHelper.style.display !='none')
        {
            if(iframe!=null)
            {
                iframe.style.display = '';
                iframe.style.width = divHelper.style.width;
                iframe.style.height = divHelper.clientHeight + 3;
                var findPosY;
                var findPosX;
                
                var obj = divHelper;
                var curtop = 0;
                var curleft = 0;
                curtop = GetY(obj,curtop)     
                curleft = GetX(obj,curleft) 
                
             
                iframe.style.left = curleft;
                iframe.style.top = curtop;
            }
        }
        else
        {
            hidePopup();   
        }
        return false;
        
    }


    //This Function called when Key Up event fire on TextCode
    function funKeyUpPopup(s,me,tblName,priField,secField,dispRows,uniqId,distFld,e,str1,str2,orderby,secFldDisplay) {  
    
        if (me!='')
            idGlbl=me.id;     

        //Assign Values to Global Varaible   
        txtCode = document.getElementById(idGlbl);       
        txtName = document.getElementById(idGlbl.replace('txtCode','txtName'));
        hdnName = document.getElementById(idGlbl.replace('txtCode','hdnName'));
        hdnCondition  = document.getElementById(idGlbl.replace('txtCode','hdnCond'));    
        divHelper = document.getElementById(idGlbl.replace('txtCode','helper'));
        hdnDistinctField = document.getElementById(idGlbl.replace('txtCode','hdnDistField'));
        hdnCode  = document.getElementById(idGlbl.replace('txtCode','hdnCode'));
        hdnRightToLeft = document.getElementById(idGlbl.replace('txtCode','hdnRightToLeft'));
        iframe = document.getElementById('iframetop');
        CalExt = document.getElementById(idGlbl.replace('txtCode','iBtnCalDate')); 
       // var wName;

        HideAllDiv(divHelper)                      
        // Decide which Browser is used. 
        x = ReturnBrowserKeycode(e);
          
        if(x==8)               
            cnt = -1;

        if(x==9) return false; //Tab key is pressed
                       
        if(x==27) //Esc key is pressed
        {
            hidePopup();
            return false;
        }
        if (divHelper.style.display !='none')
        {
            if(iframe!=null)
            {
                iframe.style.display = '';
                iframe.style.width = divHelper.style.width;
                iframe.style.height = divHelper.clientHeight + 3;
                var findPosY;
                var findPosX;
                
                var obj = divHelper;
                var curtop = 0;
                var curleft = 0;
                curtop = GetY(obj,curtop)     
                curleft = GetX(obj,curleft) 
                
             
                iframe.style.left = curleft;
                iframe.style.top = curtop;
            }
        }
        else
        {
            hidePopup();   
        }
        if (x==38) //Up arrow key is pressed
        {
            cnt=cnt-1;
            if(cnt<0)
            cnt=0;
            var d;
            if(document.getElementById('my_table'+uniqId)==null) return false;
            var rows = document.getElementById('my_table'+uniqId).getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            d=rows.length - 1;
            if (document.getElementById('trPage')!=null)
            {
                d=rows.length-2;
            }
            if(cnt==d)
            {
                cnt-=1;
            }
            
            var trId=document.getElementById(cnt+'tr'+uniqId);

            if(trId==null) return false;
           //trId.className='HelperB';
           trId.style.backgroundColor='#b1dfff';
           
            if (!document.getElementsByTagName || !document.createTextNode) return;
            for (i = 0; i < rows.length; i++) 
            {
                if(rows[i].id==cnt+'tr'+uniqId)
                {
                    txtCode.value=rows[i].childNodes.item(0).innerHTML.replace(/&nbsp;/g,' ');
                    txtCode.value=txtCode.value.replace(/&amp;/g,'&');
                    txtCode.value=txtCode.value.replace(nbspPattern," ");
                    txtCode.value=txtCode.value.replace(singleQuotePattern,"'");
                    
                    if (txtName != null)
                    {
                        txtName.value=rows[i].childNodes.item(1).innerHTML.replace(/&nbsp;/g,' ');
                        hdnName.value=rows[i].childNodes.item(1).innerHTML.replace(/&nbsp;/g,' ');
                        txtName.value=txtName.value.replace(/&amp;/g,'&');
                        hdnName.value=hdnName.value.replace(/&amp;/g,'&');
                        txtName.value=txtName.value.replace(singleQuotePattern,"'");
                        hdnName.value=hdnName.value.replace(singleQuotePattern,"'");
                    }
                }
                else
                {
                    trId=document.getElementById(i+'tr'+uniqId);
                    if(trId==null) return false;
                    trId.style.backgroundColor = 'Transparent';
                }
            }
            return false;
        }
        else if(x==40) //Down arrow key is pressed
        {
            cnt=cnt+1;
            if(document.getElementById('my_table'+uniqId)==null) return false;
            var rows = document.getElementById('my_table'+uniqId).getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            d=rows.length - 1;
            if (document.getElementById('trPage')!=null)
            {
                d=rows.length-2;
            }
            if(cnt >= d)
                cnt=d - 1;
            var trId=document.getElementById(cnt+'tr'+uniqId);
            if(trId==null)
                return false;

           //trId.className='HelperB';
           trId.style.backgroundColor='#b1dfff';
            if (!document.getElementsByTagName || !document.createTextNode) return;
            var rows = document.getElementById('my_table'+uniqId).getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            for (i = 0; i < rows.length; i++) 
            {
                    if(rows[i].id==cnt+'tr'+uniqId)
                    {
                        txtCode.value=rows[i].childNodes.item(0).innerHTML.replace(/&nbsp;/g,' ');
                        txtCode.value=txtCode.value.replace(/&amp;/g,'&');
                        txtCode.value=txtCode.value.replace(singleQuotePattern,"'");
                        txtCode.value=txtCode.value.replace(nbspPattern," ");
                        
                        if (txtName != null)
                        {
                            txtName.value=rows[i].childNodes.item(1).innerHTML.replace(/&nbsp;/g,' ');
                            hdnName.value=rows[i].childNodes.item(1).innerHTML.replace(/&nbsp;/g,' ');
                            txtName.value=txtName.value.replace(/&amp;/g,'&');
                            hdnName.value=hdnName.value.replace(/&amp;/g,'&');                            
                            txtName.value=txtName.value.replace(singleQuotePattern,"'");
                            hdnName.value=hdnName.value.replace(singleQuotePattern,"'");
                        }
                        return false;
                    }
                    else
                    {
                        trId=document.getElementById(i+'tr'+uniqId);
                        if(trId==null) return false;
                        //trId.className='HelperT'; 
                        trId.style.backgroundColor = 'Transparent';
                    }
            }
            return false;
        }
        else if(x==32 || x==13) //Space key is pressed
        {
    //////        hidePopup();
    //////        txtCode.value = trim(txtCode.value);
    //        window.location="#";
            return false;
        }
                                                                                               
        if (txtCode.value == '')
        {
            hidePopup();
            if (txtName!=null)
            {
                txtName.value='';
                hdnName.value='';
            }
            return false;
        }
        
        if (txtName==null)
        {
            wName= 48;
        }
        else
        {
            wName=parseInt(txtName.style.width)+64;
        }
        if (txtCode==null)
        {
            wCode=0; 
            hCode=0;
        }
        else
        {
            wCode=parseInt(txtCode.style.width);
            hCode=parseInt(txtCode.style.height);
        }
                        
        if (browserName=="NETSCAPE")
        { divHelper.style.marginTop=  '2px';
////                if (txtName.style.display=="none")
////                {alert('Name')
////                    divHelper.style.marginLeft= -(30+parseInt(txtCode.style.width))+'px';
////                    divHelper.style.marginTop=  (hCode + 8);
////                    
////                }
////                else
////                {alert('Code and Name')
////                    divHelper.style.marginLeft= - (wCode + wName - 20);
////                    divHelper.style.marginTop=  (hCode + 8);
////                }
        }
        else 
        { 
            if (browserName=="MICROSOFT INTERNET EXPLORER")
            {
                ////deugger
                //alert(hdnRightToLeft.value.toUpperCase())
                if ( hdnRightToLeft.value.toUpperCase() == "FALSE" )
                {
                    if (txtName.style.display=="none")
                    { 
                         if (CalExt != null)
                           {
                                //added by Palak Rathod
                                if (CalExt.style.display =="none")
                                {
                                    divHelper.style.marginLeft= -(48+parseInt(txtCode.style.width))+'px';
                                    divHelper.style.marginTop=  (hCode + 8);
                                }
                                else
                                {
                                    divHelper.style.marginLeft= -(68+parseInt(txtCode.style.width))+'px';
                                    divHelper.style.marginTop=  (hCode + 8);
                                }
                            } // end of (calext != null)
                       else
                       {
                            divHelper.style.marginLeft= -(48+parseInt(txtCode.style.width))+'px';
                            divHelper.style.marginTop=  (hCode + 8);
                       }                      
                    
                    }
                    else {
                        
                        var pattern = new RegExp("MSIE 8", "i");
                        if (pattern.test(navigator.userAgent)) {                            
                            divHelper.style.marginLeft = -(wCode + wName - 445);  //20
                            divHelper.style.marginTop = (hCode- 12);
                        }
                        else {                            
                            divHelper.style.marginLeft = -(wCode + wName - 45);  //20
                            divHelper.style.marginTop = (hCode + 8);
                        }
                        
                        
                    }
                }
                else
                {
                        if (txtName.style.display=="none")
                        {
                            //divHelper.style.marginRight= -(parseInt(divHelper.style.width)+parseInt(txtCode.style.width))+'px';
                            divHelper.style.marginLeft= -(parseInt(divHelper.style.width))-30 //- parseInt(txtCode.style.width))+5;
                            divHelper.style.marginTop=  (hCode + 8);
                        }
                        else
                        {
                            //divHelper.style.marginLeft= - (parseInt(divHelper.style.width) -(parseInt(txtCode.style.width)+9));
                            //divHelper.style.marginTop=  (hCode + 8);
                            divHelper.style.marginLeft= - (wCode + wName - 20);
                            divHelper.style.marginTop=  (hCode + 8);
                        }
                 }
            
               
               
            }
            else
            {
                //alert("What ARE you browsing with here?");
            }
        }
     
        if (!((x==39) || (x==37) ||(x==35) || (x==36) ))
        {
            if(s.toLowerCase()=="show")
	        {
	            PageMethods.GetData1(uniqId,tblName,priField,secField,dispRows,hdnCondition.value,distFld,txtCode.value,'show all',str1,str2,orderby,txtCode.style.width,txtName.style.width,secFldDisplay,onCompletePopup)
            }
	        else if (s.toLowerCase()=="next")
	        {
	            PageMethods.GetData1(uniqId,tblName,priField,secField,dispRows,hdnCondition.value,distFld,txtCode.value,'next',str1,str2,orderby,txtCode.style.width,txtName.style.width,secFldDisplay,onCompletePopup)
	        }
	        else if (s.toLowerCase()=="previous")
	        {
	            PageMethods.GetData1(uniqId,tblName,priField,secField,dispRows,hdnCondition.value,distFld,txtCode.value,'previous',str1,str2,orderby,txtCode.style.width,txtName.style.width,secFldDisplay,onCompletePopup)
            }
	        else
	        {			               
                PageMethods.GetData1(uniqId,tblName,priField,secField,dispRows,hdnCondition.value,distFld,txtCode.value,'simple',str1,str2,orderby,txtCode.style.width,txtName.style.width,secFldDisplay,onCompletePopup)
                return false;
            }
        }
    }

    function onCompletePopup(msg)
    {
        var widthName,widthCode;
        widthCode=parseInt(txtCode.style.width);
        if(txtName != null)
        {
            widthName=parseInt(txtName.style.width);
            divHelper.style.width= (widthCode+widthName+9)+'px';
        }    
        var hdnDivWidth = document.getElementById(txtCode.id.replace('txtCode','hdnDivWidth')) ;
        var hdnName = document.getElementById(txtCode.id.replace('txtCode','hdnName')) ;
        if (hdnDivWidth.value != "")
        {
            if (parseFloat(hdnDivWidth.value) != 0)
            {
                divHelper.style.width = hdnDivWidth.value.replace('px','') + 'px';
            }
        }
        divHelper.innerHTML=msg[0];
        var rcnt = divHelper.getElementsByTagName('table')[0].rows
        var cntB = CheckBrowser();
        
        for (k=0; k<rcnt.length-1; k++)
        {
            if (rcnt.item(k).childNodes.length  > 1)
                break;
            rcnt.item(k).childNodes[1].innerHTML = rcnt.item(k).childNodes[1].innerHTML.replace(singleQuotePattern,"'")
        }
        
        if (msg[1] != '')
        {
        //txtCode.value=msg[1];
        //txtCode.blur()
        //txtCode.select();
        }
        //if (msg[2] != '')
        txtName.value=msg[2];
        hdnName.value=msg[2];
         //var Code = document.getElementById(txtCode.id.replace('txtCode','hdnDivWidth')) ;
        divHelper.style.display='';
          
        if (hdnRightToLeft.value.toUpperCase() != "FALSE")
        {
            // Right Align Div
            ////deugger
            if (txtName.style.display=="none")
            {
                //divHelper.style.marginRight= -(parseInt(divHelper.style.width)+parseInt(txtCode.style.width))+'px';
                 if (browserName=="MICROSOFT INTERNET EXPLORER")
                 {
                    divHelper.style.marginLeft= -parseInt(divHelper.style.width)-30 + 'px' //- parseInt(txtCode.style.width))+5;
                    divHelper.style.marginTop=  (hCode + 8) + 'px';
                 }
                 else
                 {
                   divHelper.style.marginLeft= -(parseInt(divHelper.style.width) - parseInt(txtCode.style.width) ) + 1 +'px';
                    divHelper.style.marginTop=  '2px';
                    //divHelper.style.marginLeft= -306 + 'px' //- parseInt(txtCode.style.width))+5;
                 }
                
                //divHelper.style.marginTop=  (hCode + 8) + 'px';
            }
            else
            {   
                //divHelper.style.marginLeft= - (parseInt(divHelper.style.width) -(parseInt(txtCode.style.width)+9));
                //divHelper.style.marginTop=  (hCode + 8);
                divHelper.style.marginLeft= - (wCode + wName - 20);
                divHelper.style.marginTop=  (hCode + 8);
             }
        }
               
        if(iframe!=null)
        {
            iframe.style.display = '';
            iframe.style.width = divHelper.style.width;
            iframe.style.height = divHelper.clientHeight + 3;
            var findPosY;
            var findPosX;
            
            var obj = divHelper;
            var curtop = 0;
            var curleft = 0;
            curtop = GetY(obj,curtop)     
            curleft = GetX(obj,curleft) 
            
         
            iframe.style.left = curleft;
            iframe.style.top = curtop;
        }
        return false;
    }
    
    function GetY(obj,curtop)
    {
       // var obj = IfrRef;
        var curtop = 0;
        //var obj = document.getElementById('<%= divmain1.ClientId %>');
        //IfrRef = document.getElementById(idGlbl.replace('txtCode','helper'));
        if (document.getElementById || document.all) 
        {
            while (obj.offsetParent) 
            {
                curtop += obj.offsetTop;
                if (typeof(obj.scrollTop) == 'number')
                curtop -= obj.scrollTop;
                obj = obj.offsetParent;
            }
        }
        else if (document.layers)
        curtop += obj.y;
        return curtop;
    }

    function GetX(obj,curleft) 
    {
        //var obj = IfrRef;
        // var obj = document.getElementById('<%= divmain1.ClientId %>');
        var curleft = 0;
        if (document.getElementById || document.all) 
        {
            while (obj.offsetParent) 
            {
                curleft += obj.offsetLeft
                obj = obj.offsetParent;
            }
        }
        else if (document.layers)
        curleft += obj.x;
        return curleft;
    } 
    
    function setBackColor(obj)
    {
        //obj.className = 'HelperT';
        obj.style.backgroundColor = 'Transparent';
    }

    function setValPopup(a,b,obj)
    {
        tempobj= obj.parentNode.parentNode.parentNode;
        //obj.className = 'HelperB';        
        obj.style.backgroundColor='#b1dfff';
        var hdnC = document.getElementById(tempobj.id.replace('helper','hdnCode'))
        hdnC.value = a.replace(nbspPattern," ");
        hdnC.value = hdnC.value.replace(/&nbsp;/g,' ');           
        hdnC.value = hdnC.value.replace(/&amp;/g,'&');
        hdnC.value = hdnC.value.replace(singleQuotePattern,"'");
        
        if(txtName != null)
        {
            var hdnN = document.getElementById(tempobj.id.replace('helper','hdnName'))
            hdnN.value = b.replace(singleQuotePattern,"'");
            hdnN.value = hdnN.value.replace(/&nbsp;/g,' ');            
            hdnN.value = hdnN.value.replace(/&amp;/g,'&');
        }
    }
                    
    function setHdnCondVal(obj,targetid,condid,targetid2,condid2,targetid3,condid3,targetid4,condid4,targetid5,condid5,dispallrecs)
    {
        if(obj != null)        
        {
            var cond = document.getElementById(obj.id.replace('txtCode','hdnCond'));
            var condOrg = document.getElementById(obj.id.replace('txtCode','hdnCondOrignal'));
            var strCond="";
            if (targetid != '')
            {
                var targetval = document.getElementById(targetid);
                if (targetval!=null && targetval.value!= '')
                {
                    //condid= condid.replace('RelatedTo = Account and Relatedtoid',' RelatedTo = \'Account\' and Relatedtoid');
                    strCond += " And " + condid + "= '" + targetval.value + "'"; 
                }
                else if(targetval!=null && dispallrecs != undefined && dispallrecs.toUpperCase() == 'FALSE')
                {
                    strCond += " And " + condid + "= '" + targetval.value + "'";
                }
            }
            if (targetid2 != '')
            {
                var targetval2 = document.getElementById(targetid2);
                if (targetval2!=null && targetval2.value!= '')
                {
                    strCond += " And " + condid2 + "= '" + targetval2.value + "'"; 
                }
                else if(targetval2!=null && dispallrecs != undefined && dispallrecs.toUpperCase() == 'FALSE')
                {
                    strCond += " And " + condid2 + "= '" + targetval2.value + "'";
                }
            }            
            if (targetid3 != '')
            {
                var targetval3 = document.getElementById(targetid3);
                if (targetval3!=null && targetval3.value!= '')
                {
                    strCond += " And " + condid3 + "= '" + targetval3.value + "'"; 
                }
                else if(targetval3!=null && dispallrecs != undefined && dispallrecs.toUpperCase() == 'FALSE')
                {
                    strCond += " And " + condid3 + "= '" + targetval.value3 + "'";
                }
            }
            if (targetid4 != '')
            {
                var targetval4 = document.getElementById(targetid4);
                if (targetval4!=null && targetval4.value!= '')
                {
                    strCond += " And " + condid4 + "= '" + targetval4.value + "'"; 
                }
                else if(targetval4!=null && dispallrecs != undefined && dispallrecs.toUpperCase() == 'FALSE')
                {
                    strCond += " And " + condid4 + "= '" + targetval4.value + "'";
                }
            }
            if (targetid5 != '')
            {
                var targetval5 = document.getElementById(targetid5);
                if (targetval5!=null && targetval5.value!= '')
                {
                    strCond += " And " + condid5 + "= '" + targetval5.value + "'"; 
                }
                else if(targetval5!=null && dispallrecs != undefined && dispallrecs.toUpperCase() == 'FALSE')
                {
                    strCond += " And " + condid5 + "= '" + targetval5.value + "'";
                }
            }
            if(strCond == "" && dispallrecs != undefined && dispallrecs.toUpperCase() == 'FALSE')
            {
                cond.value=condOrg.value
            }
            else
            {
                cond.value=condOrg.value+" "+strCond;
            }
            
            if (obj.value  != '')
                obj.select();
            var helper = document.getElementById(obj.id.replace('txtCode','helper'));
            HideAllDiv(helper)
        }
    } 

    function HideAllDiv(obj)
    {
        var AllDiv = document.getElementsByTagName('DIV');
        
        for(i=0; i<AllDiv.length; i++)
        {
            if (AllDiv[i].id != "")            
            {
                if (AllDiv[i].id.search('_helper') > -1)
                {
                    if (AllDiv[i].id != obj.id)
                    {
                        AllDiv[i].style.display = 'none';
                        if(iframe!=null)
                        {          
                            iframe.style.display = 'none';
                        }
                    }
                    if(iframe!=null)
                    {          
                        iframe.style.display = 'none';
                    }
                    
                }
                
            }
           
        }
    }
    
    function hidePopup()
    {
    
        if (divHelper != null)
        {
            if(iframe!=null)
            {          
                iframe.style.display = 'none';
            }
            divHelper.innerHTML='';
            divHelper.style.display='none';                     
            PageMethods.setCurrentPageIndex1();
        }
            cnt=-1;
    } 

    function funBlurPopup(obj)
    {
        tempobj= obj.parentNode.parentNode.parentNode;
        if (tempobj != null)
        {
            divHelper = tempobj
            hidePopup()             
            document.getElementById(tempobj.id.replace('helper','txtCode')).value = document.getElementById(tempobj.id.replace('helper','hdnCode')).value//.replace(nbspPattern," ");
//            document.getElementById(tempobj.id.replace('helper','txtCode')).value = document.getElementById(tempobj.id.replace('helper','hdnCode')).value.replace(/&nbsp;/g,' ');
//            document.getElementById(tempobj.id.replace('helper','txtCode')).value = document.getElementById(tempobj.id.replace('helper','txtCode')).value.replace(/&amp;/g,'&');
            
            if (document.getElementById(tempobj.id.replace('helper','txtName')) != null)
            {
                document.getElementById(tempobj.id.replace('helper','txtName')).value = document.getElementById(tempobj.id.replace('helper','hdnName')).value//.replace(/&nbsp;/g,' ');
//                document.getElementById(tempobj.id.replace('helper','txtName')).value =document.getElementById(tempobj.id.replace('helper','txtName')).value.replace(/&amp;/g,'&');
            }
            document.getElementById(tempobj.id.replace('helper','txtCode')).focus();
            cnt=-1;
        }
    }

    function SetData(strPrmFldVal,tblName,priField,secField,dispRows,strCondition,uniqId,distFld)
    {
        PageMethods.GetName1(uniqId,tblName,priField,secField,strCondition,distFld,strPrmFldVal,onC)
    }

    function onC(msg)
    {
        txtName=document.getElementById(idGlbl.replace('txtCode','txtName'));
        hdnName=document.getElementById(idGlbl.replace('txtCode','hdnName'));
        if (txtName!=null) 
        {            
            txtName.value=msg.replace(singleQuotePattern,"'");
            hdnName.value=msg.replace(singleQuotePattern,"'");
        }
    }

    function HideDivOnBodyClick()
    {
        var AllDiv = document.getElementsByTagName('DIV');
        
        for(i=0; i<AllDiv.length; i++)
        {
            if (AllDiv[i].id != "")            
            {
                if (AllDiv[i].id.search('_helper') > -1)
                {
                    AllDiv[i].style.display = 'none';
                   if(iframe!=null)
                    {          
                        iframe.style.display = 'none';
                    }
                }
            }
        }
    }

    function ltrim ( s )
    {
        return s.replace( /^\s*/, "" );
    }

    //Function to trim the space in the right side of the string
    function rtrim ( s )
    {
        return s.replace( /\s*$/, "" );
    }


    //*Function to trim the space in the  string
    function trim(s)
    {
        var temp = s;
        return temp.replace(/^\s+/,'').replace(/\s+$/,'');
    }  


//Function for the Row selection in the Grid 
    var currentRowId = 0;
    function MarkRow(rowId)
    {
        if (document.getElementById(rowId) == null)
            return;

        if (document.getElementById(currentRowId) != null)
        {
            if ((rowId % 2) == 0)
            {
                document.getElementById(currentRowId).style.backgroundColor = '#FFFFFF';
             }
             else
            {
               document.getElementById(currentRowId).style.backgroundColor = '#EFF3FB';                
             } 
         }  
         currentRowId = rowId;
         document.getElementById(rowId).style.backgroundColor = '#D1DDF1';       
         document.getElementById(rowId).focus();      
      }
          
//check the keydown (up, down or tab ) and then send for marking the row

    function SelectRow()
    {
        if (event.keyCode == 40) //down
        {
            event.keyCode = 9; //tab
        }
        
       if ((event.keyCode == 40) || (event.keyCode == 9)) //down or tab
            MarkRow(currentRowId + 1);
        else if (event.keyCode == 38)  //up
            MarkRow(currentRowId - 1);
        else if (event.keyCode == 13)
        {
      //  //deugger;
            var theForm = document.forms['aspnetForm']; 
            theForm.submit(); 
        }     
        else if (event.keyCode == 16)//shift
            MarkRow(currentRowId - 1);     
        else
          MarkRow(currentRowId);                        
    } 
    
    function CheckBrowser()
     { 
        if (browserName ==  'NETSCAPE')
            return 1
        else
            return 0
     }
     
    function ReturnBrowserKeycode(e)
    {   
         // Decide which Browser is used.         
        if (browserName=="NETSCAPE")                    
        {                   
           return(window.event) ? event.keyCode : e.keyCode;                     
        }
        else 
        { 
            if (browserName=="MICROSOFT INTERNET EXPLORER")
            {
                return event.keyCode;
            }
            else
            {
                //alert("What ARE you browsing with here?");
            }
        }
    }
    
    //Enable And Disable Readonly Checkbox onclicking Default checkbox
    function DefaultChk(obj)
    {
        if(obj.checked == true)
        {
            ObjReadonly = document.getElementById(obj.id.replace('chkDefault','chkReadOnly'))
            ObjReadonly.disabled = false;
            ObjReadonly.parentNode.disabled = false;
        }
        else
        {
            ObjReadonly = document.getElementById(obj.id.replace('chkDefault','chkReadOnly'))
            ObjReadonly.disabled = true;
            ObjReadonly.checked=false;
            ObjReadonly.parentNode.disabled = true;
        }
    } 
      
    function ChangeHeaderAsNeeded(spanChk)
    {
        // Whenever a checkbox in the GridView is toggled, we need to
        // check the Header checkbox if ALL of the GridView checkboxes are
        // checked, and uncheck it otherwise
        var cntB = CheckBrowser();
        var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.parentNode.id).rows;
         // check to see if all other checkboxes are checked
        for(i=1;i<rows.length;i++)
        {
            var chk;
            if (rows.item(i).id=="")
            {
                chk=rows.item(i).childNodes[cntB].childNodes[cntB].childNodes[0];
                if(chk!=null)
                {
                    if(chk.type=="checkbox" && !chk.checked)
                    {
                        rows.item(0).childNodes[cntB].childNodes[cntB].childNodes[0].checked=false;
                        return;
                    }
                }
            }
        }//end for
        // If we reach here, ALL GridView checkboxes are checked        
        rows.item(0).childNodes[cntB].childNodes[cntB].childNodes[0].checked=true;
    }


//////////////////////(START)FOR ADDRESS MASTER////////////////////////
    function SetStateCountry(obj,type)
     {
        if (obj != null)
        {
            PageMethods.GetStateCountryData(obj.value, onSuccessCity, onFail, obj.id)
        }
     }
 
    function onSuccessCity(msg, Value) 
    {  
        if (Value != null && Value != '')
        {
            Obj = document.getElementById(Value)
////            ObjState = document.getElementById(Obj.id.replace('ucCity_txtCode','txtState'))
////            ObjCountry = document.getElementById(Obj.id.replace('ucCity_txtCode','txtCountry'))
////            ObjhdnState =document.getElementById(Obj.id.replace('ucCity_txtCode','hdnStateId'))
////            ObjhdnCountry =document.getElementById(Obj.id.replace('ucCity_txtCode','hdnCountryId'))
            ObjState = document.getElementById(Obj.id.replace('ucCity_txtCode','ucState_txtCode'))
            ObjCountry = document.getElementById(Obj.id.replace('ucCity_txtCode','ucCountry_txtCode'))
            ObjStateName =document.getElementById(Obj.id.replace('ucCity_txtCode','ucState_txtName'))
            ObjCountryName =document.getElementById(Obj.id.replace('ucCity_txtCode','ucCountry_txtName'))
            ObjhdnState =document.getElementById(Obj.id.replace('ucCity_txtCode','ucState_hdnName'))
            ObjhdnCountry =document.getElementById(Obj.id.replace('ucCity_txtCode','ucCountry_hdnName'))

            if (msg[0] != null && msg[0]!='')
            {
                ObjhdnState.value = msg[0];
                ObjStateName.value = msg[0];
            }
            if (msg[1] != null && msg[1]!='')
            {
                ObjhdnCountry.value = msg[1];
                ObjCountryName.value = msg[1];
            }
            if (msg[2] != null && msg[2]!='')
            {
                ObjState.value = msg[2];
            }  
            if (msg[3] != null && msg[3]!='')
            {
                ObjCountry.value = msg[3];
            }
        }
    }
    
    function GetCountry(obj)
    {   
        if (obj != null)
        {
            var StateId = document.getElementById(obj.id.replace('txtCode','txtName')).value
            PageMethods.GetCountry(StateId, onSuccessState, onFail, obj.id)
        }
    }
    
    function onSuccessState(msg, Value) 
    {  
        if (Value != null && Value != '')
        {
            Country = document.getElementById(Value.replace('ucState_txtCode','ucCountry_txtCode'))
            CountryName =document.getElementById(Value.replace('ucState_txtCode','ucCountry_txtName'))
            hdnCountry =document.getElementById(Value.replace('ucState_txtCode','ucCountry_hdnName'))

            if (msg[1] != null && msg[1]!='')
            {
                Country.value = msg[1];
            }
            if (msg[0] != null && msg[0]!='')
            {
                hdnCountry.value = msg[0];
                CountryName.value = msg[0];
            }
        }
    }
    
    function onFail(ret)
    {
        return false;
    }
     function textClear(obj)
    {
        if(obj.value == obj.defaultValue)
        {
            obj.value = '';
        }
        return false;
    }
    
   function FormatNum(obj,Pre)
    {        
       if (obj != null)
        {
          if(obj.value != "")
            {
                obj.value = parseFloat(obj.value).toFixed(Pre)
            }
        }
    }
    
   /////////////////////////(END) FOR ADDRESS MASTER//////////////////////////////////
   
   
    function ConvertInDecimal(obj,Pre)
    {        
        if(obj.value == "")
        {
            obj.value = "0.00";
            obj.value = parseFloat(obj.value).toFixed(Pre)
        }
        obj.value = parseFloat(obj.value).toFixed(Pre);
    }
    
    //////////////////////// For Control + n Key /////////////////////////////////////
    
    
    function controlN(e)
    {
       //alert(e.keyCode);
       
       if (e.keyCode==78 && e.ctrlKey)
       {
        //alert("open default window");
        //alert(window.location);
        //window.open("main.aspx")
        ////deugger
        //document.getelementbyid("abc");
        if(window.event)
        {
            e.returnValue=false;   
        }
        else
        {
            e.preventDefault();
        }
       }
        
    }
    
    //////////////////////     PDF JavaScript Without Callbakc  (added by jayesh)/////////////////////////
    
    
    
function CallBackJavasPDF()
{
    //alert('CallBackJavasPDF');
    var msg="";
//    var hdnWinNoEnc = document.getElementById('<%=hdnWinNoEnc.ClientId %>')
//    var hdnKey = document.getElementById('<%=hdnKey.ClientId %>') 

    PageMethods.PDFRunTime(msg,onCompletePDFRunTime)
    return false;
}

function CallBackJavasPDF(PrimaryKeyForPrint)
{
    //alert('CallBackJavasPDF');
    var msg="";
//    var hdnWinNoEnc = document.getElementById('<%=hdnWinNoEnc.ClientId %>')
//    var hdnKey = document.getElementById('<%=hdnKey.ClientId %>') 

    PageMethods.PDFRunTime(PrimaryKeyForPrint,onCompletePDFRunTime)
    return false;
}

function onCompletePDFRunTime(msgRet)
{
//alert(msgRet);
    if (msgRet == null)
        return;
    if (msgRet[0] == "true")
    {
        window.open(msgRet[1]);
    }
    else
    {
        alert(msgRet[1]);
    }
}

function CallBackJavasEmail(PrimaryKeyForPrint)
{
    PageMethods.EmailRunTime(PrimaryKeyForPrint,onCompleteEmailRunTime)
    return false;
}

function onCompleteEmailRunTime(msgRet)
{
//alert(msgRet);
    if (msgRet[0] == "false")
    {
        alert(msgRet[1]);
    }
    DivClose()
}

function funReturnVal(control)
{
       window.returnValue=control.outerText;
    window.close()
    return false;
}


/// Function for GetWindow Name : Added by JAYESH  on 15 Sep,2008

function getWindowName(opName)
{
    ////deugger
   var winName;
   winName=window.name;
   __doPostBack(opName,winName);
   return true;
}


/// Function for Cookies Add, Delete and Get : Added by JAYESH  on 16 Sep,2008

function setCookie(szName, szValue, szExpires, szPath, szDomain, bSecure)
{
 	var szCookieText = escape(szName) + '=' + escape(szValue);
	szCookieText += (szExpires ? '; EXPIRES=' + szExpires.toGMTString() : '');
	szCookieText += (szPath ? '; PATH=' + szPath : '');
	szCookieText += (szDomain ? '; DOMAIN=' + szDomain : '');
	szCookieText += (bSecure ? '; SECURE' : '');
	
	document.cookie = szCookieText;
}


function getCookie(szName)
{
 	var szValue = null;
	if(document.cookie)	   //only if exists
	{
       	var arr = document.cookie.split((escape(szName) + '=')); 
       	if(2 <= arr.length)
       	{
           	var arr2 = arr[1].split(';');
       		szValue  = unescape(arr2[0]);
       	}
	}
	return szValue;
}

function deleteCookie(szName)
{
 	var tmp = getCookie(szName);
	if(tmp) 
	{ setCookie(szName,tmp,(new Date(1))); }
}

/////    ************* Dirty panel Check for Report ********************* ///////////




function DirtyPanelCheckForReport(obj,e)
{

     var str = "";
 
     if ( obj.value == "Export to Excel"  )
     {
        str = 'Report Criteria has been changed...Do you want to Export data to Excel with previous Criteria?'
     }
     else if (  obj.value == "Print" )
     {
         str = 'Report Criteria has been changed...Do you want to Print data with previous Criteria?'
     }
	if (form_is_modified(document.forms[0]))	   
	
		if (confirm(str) == true)
		{		
			e.returnValue = true;
		}
		else
		{
		    e.returnValue = false;						
		}
}

 function form_is_modified(oForm)
{
	var el, opt, hasDefault, i = 0, j;
	while (el = oForm.elements[i++]) {
		switch (el.type) {
			        case 'text' :
                   	case 'textarea' :  
                   	case 'file' :                
                         	if (!/^\s*$/.test(el.value) && el.value != el.defaultValue) return true;
                         	break;
                   	case 'checkbox' :
                   	case 'radio' :
                         	if (el.checked != el.defaultChecked) return true;
                         	break;
                   	case 'select-one' :
                   	case 'select-multiple' :
                         	j = 0, hasDefault = false;
                         	while (opt = el.options[j++])
                                	if (opt.defaultSelected) hasDefault = true;
                         	j = hasDefault ? 0 : 1;
                         	while (opt = el.options[j++]) 
                                	if (opt.selected != opt.defaultSelected) return true;
                         	break;
                    
		}
	}
	return false;
}

/*


*/


function onCompgetSessionId(sessionId)
{
    ////deugger
    
    var CookieWinFeat;
    var winNoDec;
    var randomNo;
    var randomStr;
    var strWithNo;
    var arrValueonCmplt=new Array;
    var randomStrUnq;
            
    CookieWinFeat=getCookie("winFeat");  
            
            //alert(sessionId);
            //return sessionId;
             var cookieValue,wName;
            //cookieValue=getCookie(sessionId)
            cookieValue=sessionId[0];
            randomStrUnq=sessionId[1];
            if (cookieValue == "0")
            {
               // //deugger
                //setCookie(sessionId,"1");
               //setCookie(sessionId+"txt"+"1","ABCDEF");
                wName=sessionId[2]+"1";
                //cookieValue="0";
                randomStr=generateRandomString(7);
                //randomStrUnq=generateRandomString(4);
                //setCookie(sessionId+"UNQ",randomStrUnq);
                //randomStr=generateRandomString(parseInt(Math.floor(Math.random()*(10-4+1))+4,10))
//                randomNo=Math.floor((Math.random() * (randomStr.length)) + 1);
//                randomNoAdd=Math.floor((Math.random() * 5) + 1)
//                strWithNo=randomStr.substring(0,randomNo)+"1"+randomStr.substring(randomNo);
                //winNoDec=encryptFunction(strWithNo,randomNoAdd);
                //winNoDec=callWSMethodEncryption(strWithNo,randomStr)
//                arrValueonCmplt[0]=sessionId;
//                arrValueonCmplt[1]=randomNo;
//                arrValueonCmplt[2]=randomNoAdd;
//                arrValueonCmplt[3]=wName
//                arrValueonCmplt[4]=CookieWinFeat
                
                //PageMethods.EncryptString128Bit(strWithNo,randomStr,onCompltEncryptString128Bit,onFailureEncryptString128Bit,arrValueonCmplt)
                //setCookie(sessionId+"POSITION"+winNoDec.toUpperCase(),randomNo)
                //setCookie(sessionId+"ADD"+winNoDec.toUpperCase(),randomNoAdd)
            }
            else
            {
                //setCookie(sessionId,parseInt(cookieValue)+1);
                //setCookie(sessionId+"txt"+(parseInt(cookieValue)+1),"WXYZ");
                wName=sessionId[2]+(parseInt(cookieValue)+1);
                randomStr=generateRandomString(7);
                //randomStrUnq=generateRandomString(4);
                //setCookie(sessionId+"UNQ",randomStrUnq);
               /// randomStr=generateRandomString(parseInt(Math.floor(Math.random()*(10-8+1))+8,10))
//                randomNo=Math.floor((Math.random() * (randomStr.length)) + 1);
//                randomNoAdd=Math.floor((Math.random() * 5) + 1)
//                strWithNo=randomStr.substring(0,randomNo)+(parseInt(cookieValue)+1)+randomStr.substring(randomNo);
                //winNoDec=encryptFunction(strWithNo,randomNoAdd);
                //winNoDec=callWSMethodEncryption(strWithNo,randomStr)
               // PageMethods.EncryptString128Bit(strWithNo,randomStr,onCompltEncryptString128Bit)
                //setCookie(sessionId+"POSITION"+winNoDec.toUpperCase(),randomNo)
                //setCookie(sessionId+"ADD"+winNoDec.toUpperCase(),randomNoAdd)
            }
            
                randomStr="$"+randomStr;
                arrValueonCmplt[0]=sessionId;
                arrValueonCmplt[1]=randomStr + randomStrUnq
                arrValueonCmplt[2]=CookieWinFeat
                arrValueonCmplt[3]=wName
                //arrValueonCmplt[4]= parseInt(cookieValue)+1
                PageMethods.EncryptQueryStringPM(parseInt(cookieValue)+1,randomStr,randomStrUnq,onCompltEncryptQueryStringPM,onFailureEncryptQueryStringPM,arrValueonCmplt)
           
}

function onCompltEncryptQueryStringPM(winNoDec,arrValueonCmplt)
{
            ////deugger
            if(winNoDec[0].toUpperCase()=="TRUE")
            {
                alert(winNoDec[1]);
                window.open("index.aspx");
                return;
            }
    
            testwindow=window.open("Login.aspx?WinNo="+winNoDec[1]+"&Key="+arrValueonCmplt[1],arrValueonCmplt[3],arrValueonCmplt[2]);            
                        
            if (testwindow != null)
            {
            window.open('close.html', '_self');
                //window.opener='';
                //self.close()
            }
            else
            {
                ModelMsg('Popups must be allowed for this application to run properly. Refresh page after changing settings.', 3);
            }

}

function onFailureEncryptQueryStringPM()
{
    return false;
}  

function generateRandomString(len)
{
	var availChar="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	var xchar;
	var randomStr=""
	for(i=0; i<len; i++)
	{
		xchar=Math.floor(Math.random()*(availChar.length-1));
		randomStr+=availChar.charAt(xchar);
	}

	return randomStr;

}         


//NEW WINDOW OPEN
var myReq = null;
        if (window.XMLHttpRequest)
            myReq = new XMLHttpRequest();
        else if (window.ActiveXObject) 
        {
            if (new ActiveXObject("Microsoft.XMLHTTP"))
                myReq = new ActiveXObject("Microsoft.XMLHTTP");
            else
                myReq = new ActiveXObject("Msxml2.XMLHTTP");
        }

 //var myReq = new ActiveXObject("MSXML2.XMLHTTP.3.0"); 
        //var myReq = new XMLHttpRequest(); 
        function callWSMethod1() 
        { 

            ////deugger
            if (window.ActiveXObject) 
            { 
                try
                {
                    ////deugger
                    var url = "http://192.168.1.252/testdelete/GetSession.asmx?op=getSessionID" 
                   //var url = "/GetSession.asmx?op=getSessionID" 
                    //myReq.onreadystatechange = CheckStatus1; 
                    myReq.open("GET", url, false); // true indicates asynchronous request 
                    myReq.send(null);
                    //myReq.send();
                    return CheckStatus1() 
                    //alert(myReq.responseText);
                }
                catch(err)
                {
                    alert("Error From Webservice:" + err);
                }
            } 
        } 

        function CheckStatus1() 
        {
            ////deugger 
            if (myReq.readyState == 4) // Completed operation 
            { 
                myReq.open("POST","http://192.168.1.252/testdelete/GetSession.asmx/getSessionID", false); 
                //myReq.open("POST","/GetSession.asmx/getSessionID", false); 
                //myReq.send(); 
                myReq.send(null);
                res=myReq.responseText; 
                res=res.substring(0,res.lastIndexOf("<"))
                res=res.substring(res.lastIndexOf(">")+1)
                return res;
            } 
        } 
        

        function newWindowOpen()
        {
            var sessionId=PageMethods.getSessionValueWinNo(onCompgetSession)
         
        }            
        
        function onCompgetSession(sessionId)
        {           
            var cookieValue,wName;
            var arrValueonCmplt=new Array;
            ////deugger
            //cookieValue=getCookie(sessionId)
            cookieValue=sessionId[0];
            randomStrUnq=sessionId[1];
            if (cookieValue == "0")
            {
                setCookie(sessionId,"1");
                wName=sessionId[2]+"1";
                wName=sessionId[2]+"1";
                //cookieValue="0";
                randomStr=generateRandomString(7);
           }
            else
            {
               
                //setCookie(sessionId,parseInt(cookieValue)+1);
                wName=sessionId[2]+(parseInt(cookieValue)+1);
                randomStr=generateRandomString(7);
           }
            var CookieWinFeat;
            CookieWinFeat=getCookie("winFeat");
            if(CookieWinFeat==null)
            {
                CookieWinFeat="menubar=0,location=1,toolbar=1,status=1,resizable=1,scroll=1,fullscreen=0,channelmode=0,maximize=1,width=600,height=400,screenX=0,screenY=0,top=0,left=0;"
                 var expDate=new Date();
                expDate.setTime(expDate.getTime() + 1000 * 60 * 60 * 24 * 365);
                setCookie("winFeat",CookieWinFeat,expDate);
            }
   
                randomStr="$"+randomStr;
                arrValueonCmplt[0]=sessionId;
                arrValueonCmplt[1]=randomStr + randomStrUnq;
                arrValueonCmplt[2]=CookieWinFeat
                arrValueonCmplt[3]=wName
                //arrValueonCmplt[4]= parseInt(cookieValue)+1
                PageMethods.EncryptQueryStringPM(parseInt(cookieValue)+1,randomStr,randomStrUnq,onCompltEncryptQueryStringPMforMain,onFailureEncryptQueryStringPM,arrValueonCmplt)
         
        
        }
        
        
        function onCompltEncryptQueryStringPMforMain(winNoDec,arrValueonCmplt)
        {
         if(winNoDec[0].toUpperCase()=="TRUE")
            {
                alert(winNoDec[1]);
                window.open(winNoDec[2] +"/index.aspx?ErrorCode=WinNO");
                return;
            }

            window.open(winNoDec[2] + "/main.aspx?WinNo="+winNoDec[1]+"&Key="+arrValueonCmplt[1],arrValueonCmplt[3],arrValueonCmplt[2]);            
        }
        
        
        
        
/***********************************************************************************************************/        
    function GetSynchronousJSONResponse(url, postData)
    {        
        var xmlhttp = null;
        if (window.XMLHttpRequest)
            xmlhttp = new XMLHttpRequest();
        else if (window.ActiveXObject) 
        {
            if (new ActiveXObject("Microsoft.XMLHTTP"))
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            else
                xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
        }

        //url = url + "?rnd=" + Math.random(); // to be ensure non-cached version

        xmlhttp.open("POST", url, false);
        xmlhttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
        xmlhttp.send(postData);    
            
        var responseText = xmlhttp.responseText;//xmlhttp.responseXML.text;
        return responseText;
    } 
    
    function GetJSONArray(array)
    {
        var str = "";
        for(i=0; i<array.length; i++)
        {
            if (array[i] != undefined)
                str = str + "'" + array[i] + "',";
        }
        if (str != "")
        {
            str = str.substr(0,str.lastIndexOf(","));
            str = "[" + str + "]"
        }
        return str
    }
/***********************************************************************************************************/        
    
    
    function CallBackPDFPrintForReport(obj,PrintSessionName,PrintEmailOption,ReportCallType)
        {
            
            PageMethods.PDFPrint(PrintSessionName,PrintEmailOption,ReportCallType,onCompletePDFRunTimeForReport)

        }

function onCompletePDFRunTimeForReport(msgRet)
{
    if (msgRet[0] == "true")
    {
        window.open(msgRet[1]);
    }
    else if( msgRet[0] == "trueEmail")
    {
        var winNameEmail="";
        var tmpEmailOpen;
        winNameEmail=generateRandomString(16);
        window.open(msgRet[1],winNameEmail,"menubar=0,location=1,toolbar=1,status=1,resizable=1,scroll=1,fullscreen=0,channelmode=0,maximize=1,width=500,height=300,screenX=0,screenY=0,top=0,left=0;");
    }
    else if( msgRet[0] == "trueSavePdf")
    {
        return false;
    }
    else
    {
        alert(msgRet[1]);
    }
    return false;
}

function callBackPrintByWordTempalte(obj,PrintSessionName,CallReportType,hdnPrimayKeyvalue)
{
    var hdnPrimayKey=document.getElementById("<%=hdnPrimayKey.ClientId%>")
    if (hdnPrimayKeyvalue != null)
    {
        PageMethods.PrintByWordTempalte(PrintSessionName,hdnPrimayKeyvalue,CallReportType,onCompletePDFRunTimeForReport)
    }        
}   


/***********************************************************************************************************/        



 function setcase(fld)
{   
    
    var len = fld.value.length;
    var tempStr = fld.value;

      fld.value = fld.value.replace(fld.value.substring(0,(fld.value.length -(fld.value.length -1))),fld.value.substring(0,(fld.value.length -(fld.value.length -1))).toUpperCase());
} 

    function ReturnKeyCodeOnKeyPress(e)
    {        
        if ((e == "undefined" || e == null) && browserName=="NETSCAPE")       
            return;
                
        if (browserName=="NETSCAPE")                            
            return  e.charCode
        else
            return event.keyCode
    }
    
    function StopEvent(e)
    {     
        if ((e == "undefined" || e == null) && browserName=="NETSCAPE")       
            return;
            
        if (browserName=="NETSCAPE")                            
            e.preventDefault()
        else
            event.keyCode=""
        return
    }
    
    // Check whether given value is greater then 100 or not..
    function CheckDiscount(obj)
    {
        if (parseFloat(obj.value) > 100)
        {
            alert("Discount can not be greater then 100")
            obj.value = "0.00"
            obj.focus()
            obj.select()
        }
    }  
    
    
    //function for wrapping a word in mozilla or safari
    function Wordwarp()
    {		
        if (window.attachEvent == undefined)
        {
            var tag = document.getElementsByTagName("span");
            for (var i = 0; i<tag.length; i++)
            {	
                if (tag.item(i).className.toLowerCase() == "wordwradebup")
                {
                    var text = tag.item(i).innerHTML;
                    tag.item(i).innerHTML = text.replace(/(.*?)/g, "<wbr/>");
                }
            }
        }
    }
    
    //Function StockAvailability is Used To Check Stock Availability for Logistic Module
    
  function  StockAvailability(MaterialClientId,StoreClientId,PlantId,Path)
    {
             var MaterialId;
             var StoreId="";
                      
             MaterialId = document.getElementById(MaterialClientId + '_txtCode').value;
             if (StoreClientId !="")
            {
                StoreId = document.getElementById(StoreClientId + '_txtCode').value;
            }
            if (MaterialId!="")
            {
                  window.open(Path + 'AvailableStock.aspx?PlantId='+PlantId+'&StoreId='+StoreId+'&MaterialId='+MaterialId,'AvailableStock','width=500px,height=300px,top=200,left=200')
            }
          
    }
    
    //Function Used for Stock Availibility where Plant can be changed and According to That
    // Plant Stock wilbe Displayed.
    function StockAvailible(MaterialClientId,CompanyClientId,PlantClientId,Path)
    {
        var MaterialId;
        var PlantId = "";
        var CompanyId;
        
        MaterialId = document.getElementById(MaterialClientId + '_txtCode').value;
        CompanyId = document.getElementById(CompanyClientId).value;
        
        if(PlantClientId !="")
        {
            PlantId = document.getElementById(PlantClientId + '_txtCode').value;
        }
        if (MaterialId!="" && CompanyId!="")
        {
              window.open(Path + 'AvailableStock.aspx?PlantId='+PlantId+'&CompanyId='+CompanyId+'&MaterialId='+MaterialId,'AvailableStock','width=500px,height=300px,top=200,left=200')
        }
    }
        
    //Function is used where TextBox Are used for Materials in Logistics.
    function  StockAvailabilityForText(MaterialClientId,StoreClientId,PlantId,Path)
    {
        var MaterialId = document.getElementById(MaterialClientId).value; 
        if (MaterialId!="")
        {
              window.open(Path + 'AvailableStock.aspx?PlantId='+PlantId+'&MaterialId='+MaterialId,'AvailableStock','width=500px,height=300px,top=200,left=200')
        }
          
    }
    
    //Following Function is used to Show ShowAvailableStock For Sales and Distribution
     function ShowAvailableStock(MaterialClientId,SalesOrgId,CompanyId,StoreClientId,Path)
    { 
    
    var MaterialId = document.getElementById(MaterialClientId).value;
    var StoreId="";

     if (MaterialId !="")
    {
            if (SalesOrgId !="" || CompanyId !="")
            {
                if (StoreClientId !="")
                {
                    StoreId = document.getElementById(StoreClientId + '_txtCode').value;
                }
                window.open(Path + 'AvailableStock.aspx?SalesOrgId='+SalesOrgId+'&CompanyId='+CompanyId+'&StoreId='+StoreId+'&MaterialId='+MaterialId,'AvailableStock','width=500px,height=300px,top=200,left=200')
            }
        }
    }
    
    // sets value in given control
    // parameter one: ClientId of the control in which value is to be set.
    // parameter two: Value that is to be set in control.
    function SetCtrlValue(ctrlClientId,Value)
    {
        if ($get(ctrlClientId) == null)
            return
       
        ctrl = $get(ctrlClientId) 
        if (ctrl.tagName.toUpperCase() == "INPUT")
        {
            if(ctrl.type.toUpperCase() == "TEXT" || ctrl.type.toUpperCase() == "HIDDEN")
            {
                ctrl.value = Value;
            }    
            else if(ctrl.type.toUpperCase() == "CHECKBOX" || ctrl.type.toUpperCase() == "RADIO")
            {
                ctrl.checked = Value;
            }
        }
        else if(ctrl.tagName.toUpperCase() == "SPAN" || ctrl.tagName.toUpperCase() == "DIV" || ctrl.tagName.toUpperCase() == "TD")
        {
            ctrl.innerHTML = Value;
        }
        else if(ctrl.tagName.toUpperCase() == "SELECT")
        {
            ctrl.value = Value;
        }
    }
    
    // gets value of given control
    // parameter one: ClientId of the control whose value is to be retrive.
    function GetCtrlValue(ctrlClientId)
    {
        if ($get(ctrlClientId) == null)
            return ""
       
        ctrl = $get(ctrlClientId) 
        if (ctrl.tagName.toUpperCase() == "INPUT")
        {
            if(ctrl.type.toUpperCase() == "TEXT" || ctrl.type.toUpperCase() == "HIDDEN")
            {
               return ctrl.value;
            }    
            else if(ctrl.type.toUpperCase() == "CHECKBOX" || ctrl.type.toUpperCase() == "RADIO")
            {
                return ctrl.checked;
            }
        }
        else if(ctrl.tagName.toUpperCase() == "SPAN" || ctrl.tagName.toUpperCase() == "DIV" || ctrl.tagName.toUpperCase() == "TD")
        {
            return ctrl.innerHTML;
        }
        else if(ctrl.tagName.toUpperCase() == "SELECT")
        {
            return ctrl.value;
        }
    }
    
    // Added By Tanay on 29-04-2010
    function SelectAllCheckboxes1(spanChk, Column) {

        var cntB = CheckBrowser();
        var theBox = (spanChk.type == "checkbox") ? spanChk : spanChk.childNodes[0];
        xState = theBox.checked;

        var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.id).rows;
        // check to see if all other checkboxes are checked
        for (i = 0; i < rows.length; i++) {
            var chk;
            if (rows.item(i).id == "") {
                chk = rows.item(i).childNodes[cntB + Column].childNodes[0];
                if (chk != null) {
                    if (chk.type == "checkbox") {
                        chk.checked = xState;
                    }
                }
            }
        } //end for 
    }
    
     function SelectAllCheckboxes(spanChk,Column,CCol)
    {
        var cntB = CheckBrowser();
        var theBox=(spanChk.type=="checkbox")?spanChk:spanChk.childNodes[CCol];
        xState=theBox.checked;
        
        var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.id).rows;
        // check to see if all other checkboxes are checked
        for(i=1;i<rows.length;i++)
        {
            var chk;
            if (rows.item(i).id=="")
            {
                chk = rows.item(i).childNodes[cntB + Column].childNodes[CCol];
                if(chk!=null)
                {
                    if(chk.type=="checkbox")
                    {
                        chk.checked=xState;
                    }
                }
            }
        }//end for 
    }
    
    function ChangeHeaderAsNeeded1(spanChk,Column)
    {
        // Whenever a checkbox in the GridView is toggled, we need to
        // check the Header checkbox if ALL of the GridView checkboxes are
        // checked, and uncheck it otherwise
        var cntB = CheckBrowser();
        var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.id).rows;
         // check to see if all other checkboxes are checked
        for(i=1;i<rows.length;i++)
        {
            var chk;
            if (rows.item(i).id=="")
            {
                chk=rows.item(i).childNodes[cntB + Column].childNodes[0];
                if(chk!=null)
                {
                    if(chk.type=="checkbox" && !chk.checked)
                    {
                        rows.item(0).childNodes[cntB  + Column].childNodes[0].checked=false;
                        return;
                    }
                }
            }
        }//end for
        // If we reach here, ALL GridView checkboxes are checked        
        rows.item(0).childNodes[cntB + Column].childNodes[0].checked=true;
    }

    // Ended By Tanay
    function ChangeHeaderAsNeeded(spanChk, Column,CCol)
     {
        // Whenever a checkbox in the GridView is toggled, we need to
        // check the Header checkbox if ALL of the GridView checkboxes are
        // checked, and uncheck it otherwise
        var cntB = CheckBrowser();
        var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.id).rows;
        // check to see if all other checkboxes are checked
        for (i = 1; i < rows.length; i++) {
            var chk;
            if (rows.item(i).id == "") {
                if (i == 0)
                {
                     chk = rows.item(i).childNodes[cntB + Column].childNodes[CCol];
                }
                else
                {
                     chk = rows.item(i).childNodes[cntB + Column].childNodes[CCol-2];
                }
                   
                if (chk != null) {
                    if (chk.type == "checkbox" && !chk.checked) {
                        rows.item(0).childNodes[cntB + Column].childNodes[CCol].checked = false;
                        return;
                    }
                }
            }
        } //end for
        // If we reach here, ALL GridView checkboxes are checked
        rows.item(0).childNodes[cntB + Column].childNodes[CCol].checked = true;
    } 
    
    // Select all checkboxes in gridview...    
    function SelectAllCheckboxes(spanChk)
    {
        var cntB = CheckBrowser();
        var theBox=(spanChk.type=="checkbox")?spanChk:spanChk.childNodes[0];
        xState=theBox.checked;
        
        var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.parentNode.id).rows;
        // check to see if all other checkboxes are checked
        for(i=0;i<rows.length;i++)
        {
            var chk;
            if (rows.item(i).id=="")
            {
                chk=rows.item(i).childNodes[cntB].childNodes[cntB].childNodes[0];
                if(chk!=null)
                {
                    if(chk.type=="checkbox")
                    {
                        chk.checked=xState;
                    }
                }
            }
        }//end for 
    }
// Select All Checkbox in GridView....Working in all Browser
     function SelectAllCheckboxes(GridId,HeaderCheckBoxId,GridColumnNo,ChildColNo)
        {
            var cntB = CheckBrowser();

            //get reference of GridView control
            var objGrid = document.getElementById(GridId);
            //variable to contain the cell of the grid
            var cell;
            
            if (objGrid.rows.length > 0)
            {
                //loop starts from 1. rows[0] points to the header.
                for (i=1; i<objGrid.rows.length; i++)
                {
                    //get the reference of first column
                    cell = objGrid.rows[i].cells[GridColumnNo].childNodes[cntB + ChildColNo];
                    cell.checked = document.getElementById(HeaderCheckBoxId).checked;
                    
                }
            }
        }
        
        
        // Whenever a checkbox in the GridView is toggled, we need to
        // check the Header checkbox if ALL of the GridView checkboxes are
        // checked, and uncheck it otherwise
        
        // Working in all browser
        function ChangeHeaderAsNeeded(GridId,HeaderCheckBoxId,GridColumnNo,ChildColNo)
         {
       
                var cntB = CheckBrowser();
               // var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.id).rows;
                var objGrid = document.getElementById(GridId);
                var cell;
                // check to see if all other checkboxes are checked
                if(objGrid.rows.length>0)
                {
                    for (i = 1; i < objGrid.rows.length; i++) {
                                   
                                                                
                               //chk = rows.item(i).childNodes[cntB + Column].childNodes[CCol-2];
                            cell = objGrid.rows[i].cells[GridColumnNo].childNodes[cntB + ChildColNo-2];
                                                           
                            if (cell != null)
                            {
                                if (cell.type == "checkbox" && !cell.checked) {
                                    //rows.item(0).childNodes[cntB + Column].childNodes[CCol].checked = false;
                                    objGrid.rows[0].cells[GridColumnNo].childNodes[cntB + ChildColNo].childNodes[0].checked = false;
                                    return;
                                }
                            }
                        
                    } 
                }//end for
                // If we reach here, ALL GridView checkboxes are checked
                //rows.item(0).childNodes[cntB + Column].childNodes[CCol].checked = true;
                objGrid.rows[0].cells[GridColumnNo].childNodes[cntB + ChildColNo].childNodes[0].checked = true;
         } 
         function ChangeHeaderAsNeeded1(GridId,HeaderCheckBoxId,GridColumnNo,ChildColNo)
         {
       
                var cntB = CheckBrowser();
               // var rows = document.getElementById(spanChk.parentNode.parentNode.parentNode.parentNode.id).rows;
                var objGrid = document.getElementById(GridId);
                var cell;
                // check to see if all other checkboxes are checked
                if(objGrid.rows.length>0)
                {
                    for (i = 1; i < objGrid.rows.length; i++) {
                                   
                                                                
                               //chk = rows.item(i).childNodes[cntB + Column].childNodes[CCol-2];
                                cell = objGrid.rows[i].cells[GridColumnNo].childNodes[cntB + ChildColNo];
                            
                               
                            if (cell != null)
                            {
                                if (cell.type == "checkbox" && !cell.checked) {
                                    //rows.item(0).childNodes[cntB + Column].childNodes[CCol].checked = false;
                                    objGrid.rows[0].cells[GridColumnNo].childNodes[cntB + ChildColNo].checked=false;
                                    return;
                                }
                            }
                        
                    } 
                }//end for
                // If we reach here, ALL GridView checkboxes are checked
                //rows.item(0).childNodes[cntB + Column].childNodes[CCol].checked = true;
                objGrid.rows[0].cells[GridColumnNo].childNodes[cntB + ChildColNo].checked=true;
         } 
    
    function format_number(pnumber,decimals)
    {
        if (isNaN(pnumber)) { return 0};
        if (pnumber=='') { return 0};
 
        var snum = new String(pnumber);
        var sec = snum.split('.');
        var whole = parseFloat(sec[0]);
        var result = '';
 
        if(sec.length > 1)
        {
            var dec = new String(sec[1]);
            dec = String(parseFloat(sec[1])/Math.pow(10,(dec.length - decimals)));
            dec = String(whole + Math.round(parseFloat(dec))/Math.pow(10,decimals));
            var dot = dec.indexOf('.');
            if(dot == -1)
            {
                dec += '.'; 
                dot = dec.indexOf('.');
            }
            while(dec.length <= dot + decimals) { dec += '0'; }
            result = dec;
        } 
        else
        {
            var dot;
            var dec = new String(whole);
            dec += '.';
            dot = dec.indexOf('.');  
            while(dec.length <= dot + decimals) 
            { 
                dec += '0'; 
            }
            result = dec;
        } 
        return result;
    }