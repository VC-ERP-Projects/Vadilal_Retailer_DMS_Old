<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ManualClaimCust.aspx.cs" Inherits="Sales_ManualClaimCust" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript">
        var IpAddress;
        var ReasonList = [];

        $(document).ready(function () {
            $('#CountRowMaterial').val(0);
            ReLoadFn();
            AddMoreRow();
            $("#hdnIPAdd").val(IpAddress);
        });
        function imageOpen(imagedata,imageType){
            let data = imagedata;
            if(imageType=="pdf"){
                //this trick will generate a temp <a /> tag
                var link = document.createElement("a");
                link.href = imagedata;

                //Set properties as you wise
                link.download = "claim";
                link.target = "blank";

                //this part will append the anchor tag and remove it after automatic click
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
            else{  
                let w = window.open('about:blank');
                let image = new Image();
                image.src = data;
                setTimeout(function(){
                    w.document.write(image.outerHTML);
                }, 0);
            }
        }        
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
            noop = function() {},
            localIPs = {},
            ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
            key;

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }

            //create a bogus data channel
            pc.createDataChannel("");

            // create offer and set local description
            pc.createOffer(function(sdp) {
                sdp.sdp.split('\n').forEach(function(line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });
        
                pc.setLocalDescription(sdp, noop, noop);
            }, noop); 

            //listen for candidate events
            pc.onicecandidate = function(ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function(ip){
            if( IpAddress==undefined)
                IpAddress=ip;
            try{
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch(err){
            
            }
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            sender.set_contextKey("0-0-0-0-0");
        }
        
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            sender.set_contextKey("0-0-0-0-0");
        }

        function ReLoadFn() {
            var Year = <%=DateTime.Now.Year%>;
            var Month = <%=DateTime.Now.Month - 2%>;

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                },
                minDate: new Date(2014, 3, 1),
                maxDate: new Date(Year, Month, 1)
            });
            $.ajax({
                url: 'ManualClaimCust.aspx/GetItemDetails',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({}),

                success: function (result) {
                    if (result == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {
                        ReasonList = result.d[0];
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Please refresh the page...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        function RemoveMaterialRow(row) {
            $('table#tblReasonDataMapping tr#trMaterial' + row).remove();
            $('table#tblReasonDataMapping tr#trMaterial' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
            var lineNum = 0;
            $('#tblReasonDataMapping > tbody > tr').each(function (row, tr) {
                lineNum++;
                $("input[name^='txtSrNo']", this).val(lineNum);
            });
        }

        function AddMoreRow() {

            $('table#tblReasonDataMapping tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);
           
            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td><input type='text'  disabled id='txtSrNo" + ind + "' name='txtSrNo' class='txtSrNo form-control allownumericwithdecimal' /></td>"
                + "<td><select id='ddlReason" + ind + "' name='ddlReason' class='form-control'/></td>"
                + "<td><input type='text' id='AutoClaimAmt" + ind + "' name='AutoClaimAmt' onkeypress='return isNumberKeyForAmount(event);' class='form-control search' /></td>"
                + "<td><input type='text' id='AutoRemarks" + ind + "' name='AutoRemarks' MaxLength='100' class='form-control search' /></td>"
                + "<td><div id='imageContentLeft"+ ind +"' class='imageContentLeft'><input type='file' id='files" + ind + "' name='files[]' class='form-control search files' accept='image/jpeg, image/png,application/pdf' multiple /></div></td>"
                + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:23px;' onclick='RemoveMaterialRow(" + ind + ");' />"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"+"</td></tr>"

            $('#tblReasonDataMapping > tbody').append(str);

            $("#ddlReason" + ind + " option[value!='0']").remove();

            for (var i = 0; i < ReasonList.length; i++) {
                $("#ddlReason" + ind).append('<option value="' + ReasonList[i]["ReasonID"] + '">' + ReasonList[i]["ReasonName"] + '</option>');
            }

            var lineNum = 0;
            $('#tblReasonDataMapping > tbody > tr').each(function (row, tr) {
                lineNum++;
                $("input[name^='txtSrNo']", this).val(lineNum);
            });

            // allow decimal values only
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });

            if (window.File && window.FileList && window.FileReader) {
                $("#files"+ ind).on("change", function(e) {
                    if (e.target.files[0] !=null) {
                        var fileType = e.target.files[0].type;
                        var regex = new RegExp("(.*?)\.(pdf|png|jpg|jpeg)$");
                        if (regex.test(e.target.files[0].name)) {
                            var files = e.target.files,
                            filesLength = files.length;
                            if ( $("#imageContentRight"+ ind ).length>0 ) {
                                $("#imageContentLeft"+ ind).after($('> div#imageContentRight'+ ind) );
                            }
                            else {
                                $("#imageContentLeft"+ ind).after($('<div class="imageContentRight" id="imageContentRight'+ ind+'"></div>'));
                            }

                            for (var i = 0; i < filesLength; i++) {
                                var f = files[i];

                                var fileReader = new FileReader();
                                fileReader.onload = (function(e) {
                                    var file = e.target;
                                    var imagedata=e.target.result ;
                                    var divCount =$("#imageContentRight"+ ind).find('.pip').length;
                                    var fileExt=imagedata.substring(imagedata.indexOf('/') + 1, imagedata.indexOf(';base64'));
                                    var imgSrc=fileExt=="pdf"?'../Images/pdf.png':e.target.result;
                                    $("<span id=\"pip" + ind + divCount + "\" class=\"pip\">" +
                                      "<img id=\"imageThumb"+ ind + divCount+"\" class=\"imageThumb\" src=\"" + imgSrc + "\" />" +
                                      "<br/><input type='image' class=\"remove\" src='../Images/delete2.png' />"+
                                      "<input type='hidden' class=\"imghdn\" value=\"" + e.target.result + "\" />" +
                                      "</span>").appendTo("#imageContentRight"+ ind);
                                    $(".remove").click(function(){
                                        $(this).parent(".pip").remove();
                                        var lengthimage = $(this).parent(".imageContentRight").find("span[id^='pip']").length;
                                    });

                                    $("#imageThumb"+ ind + divCount).click(function () {
                                        var imgSrc = $(this).attr('src');
                                        var imghdnSrc = $(this).parent(".pip").find(".imghdn").val();
                                        if (imghdnSrc != undefined) {
                                            var imgType= imghdnSrc.substring(imghdnSrc.indexOf('/') + 1, imghdnSrc.indexOf(';base64'));
                                            imageOpen(imgType == "pdf" ? imghdnSrc : $(this).attr('src'),imgType);
                                        }
                                    });
                                });
                                fileReader.readAsDataURL(f);
                            }
                        }
                        else {
                            ModelMsg("Please upload only pdf or image", 3);
                        }
                    }
                });
            } else {
                ModelMsg("Your browser doesn't support to File API", 3);
            }
            //$('#ddlReason' + ind).on('blur', function (e, ui) {
            //    if ($('#ddlReason' + ind).val().trim() != "") {
                     
            //        var txt = $('#ddlReason' + ind).val().trim();
            //        if (txt == "undefined" || txt == "") {
            //            return false;
            //        }
            //        CheckDuplicateReason($('#ddlReason' + ind).val().trim(), ind);
            //    }
            //    //else {
            //    //    $('#ddlReason' + ind).val("");
            //    //    $('#hdnReasonID' + ind).val(0);
            //    //}
            //});
        }
        
        //function CheckDuplicateReason(ReasonCode, row) {

        //    var Item = ReasonCode.trim();
        //    var rowCnt_Reason = 1;
        //    var cnt = 0;
        //    var errRow = 0;

        //    $('#tblReasonDataMapping  > tbody > tr').each(function (row1, tr) {
        //        // post table's data to Submit form using Json Format
     
        //        var ReasonCode = $("select[name='ddlReason']").val();
        //        var LineNum = $("input[name='hdnLineNum']", this).val();

        //        if (ReasonCode != "") {
        //            if (parseInt(row) != parseInt(LineNum)) {
        //                if (Item == ReasonCode) {
        //                    cnt = 1;
        //                    errRow = row;
        //                    $('#AutoClaimAmt' + row).val('');
        //                    $('#AutoRemarks' + row).val('');
        //                    errormsg = 'Reason = ' + $('#ddlReason'+ row).find('option:selected').text() + ' is already seleted at row : ' + rowCnt_Reason;
        //                    return false;
        //                }
        //            }
        //        }
        //        rowCnt_Reason++;
        //    });

        //    if (cnt == 1) {
        //        $('#ddlReason' + row).prop('selectedIndex',0)
        //        ClearDistRow(row);
        //        ModelMsg(errormsg, 3);
        //        return false;
        //    }

        //    var ind = $('#CountRowScheme').val();
        //    if (ind == row) {
        //        AddMoreRow();
        //    }

        //}
        
        //function ClearDistRow(row) {

        //    var rowCnt_Reason = 1;
        //    var cnt = 0;

        //    $('#tblReasonDataMapping > tbody > tr').each(function (row1, tr) {
        //        // post table's data to Submit form using Json Format

        //        var ReasonCode = $("select[name='ddlReason']").val();
        //        if (ReasonCode == "") {
        //            //$(this).remove();
        //        }
        //        cnt++;

        //        rowCnt_Reason++;
        //    });

        //    if (cnt > 1) {
        //        var rowCnt_Reason = 1;
        //        $('#tblReasonDataMapping > tbody > tr').each(function (row1, tr) {
        //            // post table's data to Submit form using Json Format                    
        //            if (cnt != rowCnt_Reason) {
        //                var ReasonCode = $("select[name='ddlReason']").val();
        //                if (ReasonCode == "") {
        //                }
        //            }
        //            rowCnt_Reason++;
        //        });
        //    }

        //    var lineNum = 1;
        //    $('#tblReasonDataMapping > tbody > tr').each(function (row, tr) {
        //        $(".txtSrNo", this).text(lineNum);
        //        lineNum++;
        //    });
        //}

        function _btnCheck() {

            var IsValid = true;
            
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
 
            return IsValid;
        }

        function btnSubmit_Click() {
            $("#btnSubmit").attr('disabled', 'disabled');

            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (!IsValid) {
                $.unblockUI();
                return false;
            }

            var TableData_Material = [];

            var totalItemcnt = 0;
            var cnt = 0;
            rowCnt_Material = 0;

            $('#tblReasonDataMapping  > tbody > tr').each(function (row, tr) {
                var Images = new FormData();
                var ImageList = [];

                //$.each($(".files"), function(i, obj) {
                //    $.each(obj.files,function(i,file){
                //        ImageList.push($(file).attr('src'));
                //    });
                //});
                $('.pip').children('img').each(function() {
                    //ImageList.push($(this).attr('src').replace(/^data:image\/[a-z]+;base64,/, ""));
                    ImageList.push($(this).attr('src').split(',')[1]);

                });
                totalItemcnt = 1;
                var ReasonID = $(this).find('option:selected').val();
                var ClaimAmt = $("input[name='AutoClaimAmt']", this).val();
                var Remarks = $("input[name='AutoRemarks']", this).val();

                var obj = {
                    ReasonID : ReasonID,
                    ClaimAmt: ClaimAmt,
                    Remarks: Remarks,
                    ImageList:ImageList
                };
                TableData_Material.push(obj);
                rowCnt_Material++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please select atleast one Item", 3);
                event.preventDefault();
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }

            $('#hidJsonInputMaterial').val(JSON.stringify(TableData_Material));

            var totalItemcnt = 0;
            cnt = 0;
          
            var successMSG = false;
            var ManualClaimData = $('#hidJsonInputMaterial').val();
            var successMSG = true;

            if (successMSG == false) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                event.preventDefault();
                return false;
            }
            else {
                var successMSG = true;
                var sv = $.ajax({
                    url: 'ManualClaimCust.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputData: ManualClaimData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(),ClaimDate:$('.txtDate').val(),IPAdd:$('#hdnIPAdd ').val()}),
                    contentType: 'application/json; charset=utf-8'
                });

                var sendcall = 0;
                sv.success(function (result) {
                    if (result.d == "") {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d.indexOf("WARNING=") >= 0) {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        if (sendcall == 1) {
                            alert(SuccessMsg);
                            location.reload(true);
                            event.preventDefault();
                            return false;
                        }
                    }
                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    $.unblockUI();
                    return false;
                });
            }

            if (sendcall == 0) {
                event.preventDefault();
                sendcall = 1;
                return false;
            }
        }
    </script>
    <style>
        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 4px 6px 3px;
        }

        #tblReasonDataMapping, #tblReasonDataMapping .form-control {
            font-size: 12px;
            max-height: none;
            padding: 3px 6px;
            height: AUTO;
        }

        .ui-datepicker-calendar {
            display: none;
        }

        input[type="file"] {
            display: block;
        }

        .imageThumb {
            max-height: 75px;
            padding: 1px;
            cursor: pointer;
            width: 100%;
            height: 60px;
        }

        .pip {
            display: inline-block;
            margin: 5px 3px 0 0;
            width: 10%;
        }

        .remove {
            display: block;
            background: white;
            width: 30%;
            cursor: pointer;
            margin: 0 auto;
        }

            .remove:hover {
                background: white;
                background: #444;
                color: black;
            }

        .imageContentLeft {
            display: inline-block;
            float: left;
            margin: 0 1% 0 0;
        }

        .imageContentRight {
            /*display: inline-block;*/
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDate" runat="server" Text="Claim Process Month" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDate" runat="server" TabIndex="1" MaxLength="7" CssClass="onlymonth txtDate form-control"></asp:TextBox>
                        <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtDist" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetDistCurrHierarchy" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" id="CountRowMaterial" />
                        <input type="button" id="btnAddMoreMaterial" tabindex="3" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRow();" class="btn btn-default" />
                    </div>
                </div>
            </div>
            <div class="row" style="display: none">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="border-la">&nbsp;</div>
            <table id="tblReasonDataMapping" class="table" border="1" tabindex="10">
                <thead>
                    <tr class="table-header-gradient">
                        <th style="width: 3%;">Sr.No</th>
                        <th style="width: 15%">Reason Code</th>
                        <th style="width: 6%">Claim Amount</th>
                        <th style="width: 7%">Remarks</th>
                        <th style="width: 40%">Images</th>
                        <th style="width: 3%">Delete</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <input type="submit" value="Save" class="btn btn-default" id="btnSubmit" onclick="return btnSubmit_Click();" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
    </div>
</asp:Content>

