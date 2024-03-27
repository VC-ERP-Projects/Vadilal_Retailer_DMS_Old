<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CallValidation.aspx.cs" Inherits="Call_Validation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script>
        var IpAddress;
        $(function () {
            Reload();
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function ReloadPage() {
            __doPostBack('Refresh', 'Refresh');

        }
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
            noop = function () { },
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
            pc.createOffer(function (sdp) {
                sdp.sdp.split('\n').forEach(function (line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });

                pc.setLocalDescription(sdp, noop, noop);
            }, noop);

            //listen for candidate events
            pc.onicecandidate = function (ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function (ip) {
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });
        function Reload() {
            $("#gvCallValidation").tableHeadFixer('77vh');
            //AddMoreRow();
            FillData();
          
        }
        function EndRequestHandler2(sender, args) {
            Reload();
        }
        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
        }
        function FillData() {

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

            $.ajax({
                url: 'CallValidation.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    $.unblockUI();

                    if (result.d == "") {
                        //ClearAll();
                        $.unblockUI();
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);

                        event.preventDefault();

                        return false;
                    }
                    else {
                        var items = result.d[0];
                        if (items.length > 0) {
                            $('#gvCallValidation  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var row = 1;
                            $('#CountRowCallDetail').val(0);

                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowCallDetail').val();
                                $('#hdnCallValID' + row).val(items[i].CallValidationID);
                                $('#hdnEmpID' + row).val(items[i].EmpID);
                                $('#hdnGroupID' + row).val(items[i].EmpGroupId);
                                $('#txtEmpGroupDesc' + row).val(items[i].EmpGroupDesc);
                                if ($('#hdnGroupID' + row).val() != "0" && $('#hdnGroupID' + row).val() != undefined) {
                                    $('#txtEmpGroupDesc' + row).attr("disabled", "disabled");
                                }
                                //$('#txtProdCall' + row).val(items[i].PRCall).attr("disabled", "disabled");
                                //$('#txtNonProdCall' + row).val(items[i].NPRCall).attr("disabled", "disabled");
                                $('#txtTCall' + row).val(items[i].TotalCall);
                                $('#tdCreateBy' + row).text(items[i].CreatedBy);
                                $('#tdCreateOn' + row).text(items[i].CreatedDate);
                                $('#tdCreateIpAddress' + row).text(items[i].CreatedIPAddress);
                                $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                $('#tdUpdateOn' + row).text(items[i].UpdatedDate);
                                $('#tdUpdateIpAddress' + row).text(items[i].UpdateIPAddress);

                            }
                        }
                    }
                    AddMoreRow();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        function AddMoreRow() {

            $('#gvCallValidation tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowCallDetail').val();
            ind = parseInt(ind) + 1;
            $('#CountRowCallDetail').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                //+ "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='txtEmpGroupDesc" + ind + "' name='txtEmpGroupDesc' onchange='ChangeData(this);' class='form-control search' style='background-color: rgb(250, 255, 189);'/></td>"
                //+ "<td><input type='text' id='txtProdCall" + ind + "' disabled='disabled' name='txtProdCall' class='form-control search'/></td>"
                //+ "<td><input type='text' id='txtNonProdCall" + ind + "'disabled='disabled' name='txtNonProdCall' class='form-control search'/></td>"
                + "<td><input type='text' id='txtTCall" + ind + "' name='txtTCall' onchange='ChangeData(this);' class='form-control allownumericwithoutdecimal search'/></td>"
                + "<td id='tdCreateOn" + ind + "' class='tdCreateOn'></td>"
                + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
                  + "<td id='tdCreateIpAddress" + ind + "' class='tdCreateIpAddress'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateIpAddress" + ind + "' class='tdUpdateIpAddress'></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></td>"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' id='hdnGroupID" + ind + "' name='hdnGroupID' /></td>"
                + "<input type='hidden' id='hdnCallValID" + ind + "' name='hdnCallValID' /></td>"
                + "<input type='hidden' id='hdnEmpID" + ind + "' name='hdnEmpID' /></td></tr>";

            $('#gvCallValidation > tbody').append(str);

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('#txtEmpGroupDesc' + ind).autocomplete({
                source: function (Request, Response) {
                    $.ajax({
                        url: 'CallValidation.aspx/LoadCustomerByType',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ prefixText: Request.term }),
                        async: false,
                        contentType: 'application/json; charset=utf-8',
                        success: function (result) {
                            if (result.d == "") {
                                return false;
                            }
                            else if (result.d[0].indexOf("ERROR=") >= 0) {
                                var ErrorMsg = result.d[0].split('=')[1].trim();
                                ModelMsg(ErrorMsg, 3);
                                return false;
                            }
                            else {
                                Response(result.d[0]);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert('Something is wrong...' + XMLHttpRequest.responseText);
                            return false;
                        }
                    });
                },
                minLength: 0,
                scroll: true
            });
           
            $(".allownumericwithoutdecimal").on("keypress keyup", function (event) {
                $(this).val($(this).val().replace(/[^\d].+/, ""));
                if ((event.which < 48 || event.which > 57)) {
                    event.preventDefault();
                }
            });
            $('#txtEmpGroupDesc' + ind).on('autocompleteselect', function (e, ui) {
                $('#txtEmpGroupDesc' + ind).val(ui.item.value);
                GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#txtEmpGroupDesc' + ind).on('change keyup', function () {
                if ($('#txtEmpGroupDesc' + ind).val() == "") {
                    ClearCustomerRow(ind);
                }
            });

            $('#txtEmpGroupDesc' + ind).on('blur', function (e, ui) {
                if ($('#txtEmpGroupDesc' + ind).val().trim() != "") {
                    if ($('#txtEmpGroupDesc' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Employee", 3);
                        $('#txtEmpGroupDesc' + ind).val("");
                        $('#hdnCustomerID' + ind).val('0');
                        return;
                    }
                    var txt = $('#txtEmpGroupDesc' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicateCustomer($('#txtEmpGroupDesc' + ind).val().trim(), ind);
                }
            });


            var lineNum = 1;
            $('#gvCallValidation > tbody > tr').each(function (row, tr) {
                //$(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function CheckDuplicateCustomer(CustCode, row) {

            var Item = CustCode.split("-")[0].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvCallValidation  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                if (CustCode != undefined && CustCode != "") {

                    CustCode = CustCode.split("-")[0].trim();

                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                //$('#txtProdCall' + row).val('');
                                //$('#txtNonProdCall' + row).val('');
                                $('#txtTCall' + row).val('');
                                errormsg = 'Employee = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                    rowCnt_Customer++;
                }
            });

            if (cnt == 1) {
                $('#txtEmpGroupDesc' + row).val('');
                ClearCustomerRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCallDetail').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function ClearCustomerRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#gvCallValidation > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#gvCallValidation > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                        if (CustCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#gvCallValidation > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function GetCustomerDetailsByCode(CustCode, row) {

            var CustCode = CustCode.split("-").pop().trim();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvCallValidation  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var Item = $("input[name='txtEmpGroupDesc']", this).val();
                if (Item != undefined && Item != "") {
                    Item = Item.split("-").pop().trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                return false;
                            }
                        }
                    }
                    rowCnt_Material++;
                }
            });

            if (cnt == 1) {
                return false;
            }
            else {

                $.ajax({
                    url: 'CallValidation.aspx/GetCustomerDetail',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ EmpID: CustCode }),
                    success: function (result) {
                        if (result == "") {
                            return false;
                        }
                        else if (result.d.indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='txtEmpGroupDesc']", this).val() == "";
                            return false;
                        }
                        else {
                            //$('#txtProdCall' + row).val(result.d[0].ProdCall);
                            //$('#txtNonProdCall' + row).val(result.d[0].NonProdCall);
                            $('#txtTCall' + row).val(result.d[0].TotalCall);
                            $('#tdCreateBy' + row).text(result.d[0].CreatedBy);
                            $('#tdCreateOn' + row).text(result.d[0].CreatedDate);
                            $('#tdUpdateBy' + row).text(result.d[0].UpdatedBy);
                            $('#tdUpdateOn' + row).text(result.d[0].UpdatedDate);
                            $('#tdCreateIpAddress' + row).text(result.d[0].CreatedIPAddress);
                            $('#tdUpdateIpAddress' + row).text(result.d[0].UpdateIPAddress);
                            $('#hdnEmpID' + row).val(result.d[0].EmpID);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });
            }

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
        }

        function btnSubmit_Click() {

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

            var TableData_Customer = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Customer = 0;

            $('#gvCallValidation  > tbody > tr').each(function (row, tr) {
                var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                if (CustCode != "") {
                    totalItemcnt = 1;
                    var EmpID = $("input[name='hdnEmpID']", this).val().trim();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    var CallValID = $("input[name='hdnCallValID']", this).val().trim();
                    //var ProdCall = $("input[name='txtProdCall']", this).val();
                    //var NonProdCall = $("input[name='txtNonProdCall']", this).val();
                    var TCall = $("input[name='txtTCall']", this).val();
                    var EmpGroupID = $("input[name='hdnGroupID']", this).val();

                    var obj = {
                        EmpID: EmpID,
                        CallValID: CallValID,
                        //ProdCall: ProdCall,
                        //NonProdCall: NonProdCall,
                        TCall: TCall,
                        IsChange: IsChange,
                        EmpGroupID: EmpGroupID
                    };
                    TableData_Customer.push(obj);
                }
                rowCnt_Customer++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please select atleast one Item", 3);
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                return false;
            }

            var CustomerData = JSON.stringify(TableData_Customer);

            var successMSG = true;

            var sv = $.ajax({
                url: 'CallValidation.aspx/SaveData',
                type: 'POST',
                //async: false,
                dataType: 'json',
                // traditional: true,
                data: JSON.stringify({ hidJsonInputCustomer: CustomerData, IPAddress: $("#hdnIPAdd").val() }),
                contentType: 'application/json; charset=utf-8'
            });

            var sendcall = 0;

            sv.success(function (result) {

                if (result.d == "") {
                    $.unblockUI();
                    return false;
                }
                else if (result.d.indexOf("ERROR=") >= 0) {
                    $.unblockUI();
                    var ErrorMsg = result.d.split('=')[1].trim();
                    ModelMsg(ErrorMsg, 2);
                    return false;
                }
                else if (result.d.indexOf("WARNING=") >= 0) {
                    $.unblockUI();
                    var ErrorMsg = result.d.split('=')[1].trim();
                    ModelMsg(ErrorMsg, 3);
                    return false;
                }
                if (result.d.indexOf("SUCCESS=") >= 0) {
                    var SuccessMsg = result.d.split('=')[1].trim();
                    alert(SuccessMsg);
                    location.reload(true);
                    return false;
                }

            });

            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                $.unblockUI();
                alert('Something is wrong...' + XMLHttpRequest.responseText);
                return false;
            });
        }

    </script>

    <style type="text/css">
        .ui-widget {
            font-size: 11px;
        }

        .HideColumn {
            display: none;
        }

        #gvCallValidation td input {
            font-size: 12px;
            height: 30px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <input type="hidden" id="CountRowCallDetail" />
            <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <table id="gvCallValidation" class="table gvCallValidation" border="1" tabindex="6" style="width: 100%; border-collapse: collapse; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 20%">Category</th>
                            <th style="width: 4%">Total Call</th>
                            <th style="width: 6%">Created Date/Time</th>
                            <th style="width: 10%">Created By</th>
                            <th style="width: 10%">Created IPAddress</th>
                            <th style="width: 6%">Updated Date/Time</th>
                            <th style="width: 10%">Updated By</th>
                            <th style="width: 10%">Updated IPAddress</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="18" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="2" CssClass="btn btn-default" OnClick="btnCancelClick" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>


</asp:Content>

