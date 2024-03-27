<%@ Page Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="BrandingCheckerMaster.aspx.cs" Inherits="Master_Branding_Checker_Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">
        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';

        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            try {
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                noop = function () { },
                localIPs = {},
                ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                key;
            }
            catch (err) {

            }

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }
            try {
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
            catch (err) {

            }
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

        $(document).ready(function () {
            ClearControls();

            $("#tblBrandChk").tableHeadFixer('80vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })

            FillData();
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', true);
                    $(this).val('Edit');
                }
            })

        });

        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }

        function ClearControls() {

            $('.divBrandChkEntry').attr('style', 'display:none;');
            $('.divBrandChkReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblBrandChk tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvBrandChkHistory')) {
                $('.gvBrandChkHistory').DataTable().destroy();
            }
            $('.gvBrandChkHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divBrandChkReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divBrandChkEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowBrand').val(0);
                AddMoreRow();
                FillData();
            }
        }

        function AddMoreRow() {

            $('table#tblBrandChk tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table 
            var ind = $('#CountRowBrand').val();
            ind = parseInt(ind) + 1;
            $('#CountRowBrand').val(ind);

            var str = "";
            str = "<tr id='trBrand" + ind + "'>"
                + "<td class='txtSrNo' name='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveBrandRow(" + ind + ");' /></td>"
                + "<td><input type='text' id='AutoEmpName" + ind + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive'  class='checkbox'  onchange='ChangeData(this);'/></td>"
                + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
                + "<td id='tdCreateOn" + ind + "' class='tdCreateOn dtbodyCenter'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn dtbodyCenter'></td>"
                + "<input type='hidden' class='hdnCheckID' id='hdnCheckID" + ind + "' name='hdnCheckID' />"
                + "<input type='hidden' class='hdnEmpID' id='hdnEmpID" + ind + "' name='hdnEmpID' />"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='IsDeleted' id='IsDeleted" + ind + "' name='IsDeleted' value='0' /></td>"
                + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />"
                      
            $('#tblBrandChk > tbody').append(str);
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);


            //---------------Employee List selection----------
            $('#AutoEmpName' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "BrandingCheckerMaster.aspx/LoadEmployee",
                        type: 'POST',
                        dataType: "json",
                        data: JSON.stringify({ prefixText: request.term }),
                        contentType: "application/json; charset=utf-8",
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
                                response(result.d[0]);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                select: function (event, ui) {
                    $('#hdnEmpID' + ind).val(ui.item.value.split('#')[2].trim());
                    $('#AutoEmpName' + ind).val(ui.item.value + " ");
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoEmpName' + ind).val("");
                        $('#hdnEmpID' + ind).val(0);
                        $('#chkIsActive' + ind).prop('checked', false);
                        $('#chkIsActive' + ind).attr("disabled", false);
                    }
                },

                open: function (event, ui) {
                    var txttopposition = $('#AutoEmpName' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                         inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoEmpName' + ind).position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top; //top - height;//ind >= 6 ? top - height : top;
                    $results.css("top", newTop + "px");
                },

                minLength: 1,
                scroll: true
            });

            $('#AutoEmpName' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoEmpName' + ind).val(ui.item.value);

            });
            $('#AutoEmpName' + ind).on('change keyup', function () {
                if ($('#AutoEmpName' + ind).val() == "") {
                    ClearEmpRow(ind);
                }
            });

            $('#AutoEmpName' + ind).on('blur', function (e, ui) {
                if ($('#AutoEmpName' + ind).val().trim() != "") {
                    if ($('#AutoEmpName' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee", 3);
                        $('#AutoEmpName' + ind).val("");
                        $('#hdnEmpID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoEmpName' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateEmp($('#AutoEmpName' + ind).val().trim(), ind);
                }
            });

            var lineNum = 1;
            $('#tblBrandChk > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function CheckDuplicateEmp(EmpCode, row) {
            var Item = EmpCode.split("#")[0].trim();
            var rowCnt_Emp = 1;
            var cnt = 0;
            var errRow = 0;
          
            $('#tblBrandChk  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var EmpCode = $("input[name='AutoEmpName']", this).val();

                if (EmpCode != undefined && EmpCode != "") {

                    EmpCode = EmpCode.split("#")[0].trim();

                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (EmpCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == EmpCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoEmpName' + row).val("");
                                $('#hdnEmpID' + row).val(0);
                                errormsg = 'Employee = ' + EmpCode + ' is already seleted at row : ' + rowCnt_Emp;
                                return false;
                            }
                        }
                    }
                    rowCnt_Emp++;
                }
            });

            if (cnt == 1) {
                $('#AutoEmpName' + row).val('');
                ClearEmpRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }
            var ind = $('#CountRowBrand').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function ClearEmpRow(row) {

            var rowCnt_Emp = 1;
            var cnt = 0;

            $('#tblBrandChk > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var EmpName = $("input[name='AutoEmpName']", this).val();

                if (EmpName == "") {
                    //$(this).remove();
                }
                cnt++;
                rowCnt_Emp++;
            });
            if (cnt > 1) {
                var rowCnt_Emp = 1;
                $('#tblBrandChk > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Emp) {
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        if (EmpName == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Emp++;
                });
            }
            var lineNum = 1;
            $('#tblBrandChk > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function RemoveBrandRow(row) {
            var BrandChkID = $('table#tblBrandChk tr#trBrand' + row).find(".hdnCheckID").val();
            $('table#tblBrandChk tr#trBrand' + row).find(".IsChange").val("1");
            $('table#tblBrandChk tr#trBrand' + row).remove();
            $('table#tblBrandChk tr#trBrand' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = BrandChkID + "/,";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblBrandChk tr#trBrand' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }

        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            CheckDuplicateEmp($(txt).parent().parent().find("input[name='AutoEmpName']").val(), Number($(txt).parent().parent().find("input[name='hdnLineNum']").val()));
        }

        function FillData() {

            var IsValid = true;

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

            $.ajax({
                url: 'BrandingCheckerMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    $.unblockUI();

                    if (result.d == "") {
                        $.unblockUI();
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);

                        event.preventDefault();
                        return false;
                    }

                    else {
                        var items = result.d[0];// result.d

                        if (items.length > 0) {
                            $('#tblBrandChk  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });

                            var row = 1;
                            $('#CountRowBrand').val(0);
                            var ind = $('#CountRowBrand').val();
                            ind = parseInt(ind) + 1;
                            $('#CountRowBrand').val(ind);
                            var items = result.d[0];

                            var ind = 0;
                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                var trHTML = '';                                
                                var ind = parseInt(i) + 1;
                                row = $('#CountRowBrand').val();
                                $('#chkEdit' + row).click();
                                $('#chkEdit' + row).prop("checked", false);
                                $('#AutoEmpName' + row).val(items[i].EmpName);
                                if (items[i].IsActive == "False") {
                                    $('#chkIsActive' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkIsActive' + row).prop("checked", true);
                                }
                                $('#tdCreateBy' + row).text(items[i].CreatedBy);
                                $('#tdCreateOn' + row).text(items[i].CreatedDate);
                                $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                $('#tdUpdateOn' + row).text(items[i].UpdatedDate);
                                $('#hdnCheckID' + row).val(items[i].CheckID);
                                $('#hdnEmpID' + row).val(items[i].EmpName);
                                $('#hdnLineNum' + row).val(row);
                                $('.chkEdit').prop("checked", false);
                                $('.btnEdit').click();
                                //trHTML += "<tr id='trBrand" + ind + "'>"
                                //+ "<td class='txtSrNo' name='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                                //+ "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                                //+ "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                                //+ "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveBrandRow(" + ind + ");' /></td>"
                                //+ "<td><input type='text' id='AutoEmpName" + ind + "' name='AutoEmpName' value = '" + item.EmpName + "' onchange='ChangeData(this);' class='form-control search AutoEmpName' /></td>"
                                //+ "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' class='checkbox' onchange='ChangeData(this);'/></td>"// + item[i].IsActive == 'false' ? '' : 'checked' +                                 
                                //+ "<td id='tdCreateBy" + ind + "' class='tdCreateBy'>" + item.tdCreateBy + "</td>"
                                //+ "<td id='tdCreateOn" + ind + "' class='tdCreateOn dtbodyCenter'>" + item.CreatedDate + "</td>"
                                //+ "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'>" + item.UpdatedBy + "</td>"
                                //+ "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn dtbodyCenter'>" + item.UpdatedDate + "</td>"
                                //+ "<input type ='hidden' class='hdnCheckID' id = 'hdnCheckID" + ind + "'name = 'hdnCheckID' value =" + item.CheckID + "/>"
                                //+ "<input type='hidden' class='hdnEmpID' id='hdnEmpID" + ind + "' name='hdnEmpID' value=" + item.EmpName + " />"
                                //+ "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "'/>"
                                //+ "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                                //+ "<input type='hidden' class='IsDeleted' id='IsDeleted" + ind + "'name='IsDeleted' value='0' /></td>"
                                //+ "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />" + '</tr>';
                               
                                //$('#tblBrandChk > tbody').append(trHTML);
                                //$('#CountRowBrand').val(ind);
                                //$('#trBrand' + ind).find('input[type="checkbox"]').prop("checked", item.IsActive);

                            };
                            //--Autofill employee at Edit time--
                            $(".AutoEmpName").autocomplete({
                                source: function (request, response) {
                                    $.ajax({
                                        url: "BrandingCheckerMaster.aspx/LoadEmployee",
                                        type: 'POST',
                                        dataType: "json",
                                        data: JSON.stringify({ prefixText: request.term }),
                                        contentType: "application/json; charset=utf-8",
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
                                                response(result.d[0]);
                                            }
                                        },
                                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                                        }
                                    });
                                },
                                select: function (event, ui) {
                                    $('#hdnEmpID' + ind).val(ui.item.value.split('-')[2].trim());
                                    $('#AutoEmpName' + ind).val(ui.item.value + " ");
                                    $('#chkIsActive' + ind).prop('checked', false);
                                    $('#chkIsActive' + ind).attr("disabled", false);

                                },
                                change: function (event, ui) {
                                    if (!ui.item) {
                                        $('#AutoEmpName' + ind).val("");
                                        $('#hdnEmpID' + ind).val(0);
                                        $('#chkIsActive' + ind).prop('checked', false);
                                        $('#chkIsActive' + ind).attr("disabled", false);

                                    }
                                },
                                minLength: 1,
                                scroll: true
                            });

                            $('#AutoEmpName' + ind).on('change keyup', function () {
                                if ($('#AutoEmpName' + ind).val() == "") {
                                    ClearEmpRow(ind);
                                }
                            });

                            $('#AutoEmpName' + ind).on('blur', function (e, ui) {
                                if ($('#AutoEmpName' + ind).val().trim() != "") {
                                    if ($('#AutoEmpName' + ind).val().indexOf('-') == -1) {
                                        ModelMsg("Select Proper Employee", 3);
                                        $('#AutoEmpName' + ind).val("");
                                        $('#hdnEmpID' + ind).val('0');
                                        return;
                                    }
                                    var txt = $('#AutoEmpName' + ind).val().trim();
                                    if (txt == "undefined" || txt == "") {
                                        //ModelMsg("Enter Item Code Or Name", 3);
                                        return false;
                                    }
                                    CheckDuplicateEmp($('#AutoEmpName' + ind).val().trim(), ind);
                                }
                            });

                            $('.search,.checkbox').prop('disabled', true);

                            $('.chkEdit').hide();
                            $('.chkEdit').prop("checked", true);
                            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);


                            var lineNum = 1;
                            $('#tblBrandChk > tbody > tr').each(function (row, tr) {
                                $(".txtSrNo", this).text(lineNum);
                                lineNum++;
                            });
                        }
                    }
                    AddMoreRow();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    ModelMsg("Select Proper Employee", 3);
                    $('.txtCode').val("");
                    event.preventDefault();
                    return false;
                }
            });

        }

        function Cancel() {
            window.location = "../Master/BrandingCheckerMaster.aspx";
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

            var TableData_Employee = [];
            var totalItemcnt = 0;
            var cnt = 0;
            rowCnt_Emp = 0;

            $('#tblBrandChk  > tbody > tr').each(function (row, tr) {

                var EmpName = $("input[name='AutoEmpName']", this).val();
                var IsDeleted = $('#hdnIsRowDeleted').val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                if (EmpName != "" && (IsChange == "1" || IsDeleted == 1)) {//&& (IsChange == "1" || IsDeleted == 1)
                    totalItemcnt = 1
                    //var EmpdID = $("input[name='hdnEmpID']", this).val();
                    var ChekerID = $("input[name='hdnCheckID']", this).val();
                    var EmpID = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    var IsDeleted = $("input[name='IsDeleted']", this).is(':checked');

                    if ((EmpID == "") ) {
                        ModelMsg('Please select proper Employee at row : ' + (rowCnt_Emp + 1), 3);
                        IsValid = false;
                    }

                    var obj = {
                        EmpID: EmpID,
                        CheckID: ChekerID,
                        //EmpdID: EmpdID,                       
                        IsActive: IsActive,
                        IsChange: IsChange
                         
                    };
                    TableData_Employee.push(obj);
                }
                rowCnt_Emp++;

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

            var EmpData = JSON.stringify(TableData_Employee);

            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'BrandingCheckerMaster.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputEmp: EmpData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val() }),
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
            else {
                $.unblockUI();
            }
        }

        function ExportXLS(xlsx, numrows) {
            var sheet = xlsx.xl.worksheets['sheet1.xml'];
            var clR = $('row', sheet);

            //update Row
            clR.each(function () {
                var attr = $(this).attr('r');
                var ind = parseInt(attr);
                ind = ind + numrows;
                $(this).attr("r", ind);
            });

            // Create row before data
            $('row c ', sheet).each(function () {
                var attr = $(this).attr('r');
                var pre = attr.substring(0, 1);
                var ind = parseInt(attr.substring(1, attr.length));
                ind = ind + numrows;
                $(this).attr("r", pre + ind);
            });

            return sheet;
        }

        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                else
                    value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();

                $.ajax({
                    url: 'BrandingCheckerMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "'}",
                    success: function (result) {
                        if (result.d[0] == "" || result.d[0] == undefined) {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoEmpName']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].Employee + "</td>"
                                        + "<td>" + ReportData[i].IsActive + "</td>"
                                        //+ "<td>" + ReportData[i].Deleted + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"

                                $('.gvBrandChkHistory > tbody').append(str);
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvBrandChkHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 6 });

                    $('.gvBrandChkHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '80vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   //data += 'Type,' + $('.ddlType option:selected').text() + '\n';
                                   data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                   data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                   data += 'Created on,' + jsDate.toString() + '\n';
                                   return data + csv;
                               },
                               exportOptions: {
                                   format: {
                                       body: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       },
                                       footer: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       }
                                   }
                               }
                           },
                           {
                               extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 5);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);                                
                                   var r1 = Addrow(2, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'landscape', //portrait
                               pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                               title: $("#lnkTitle").text(),
                               footer: 'false',
                               exportOptions: {
                                   columns: ':visible',
                                   search: 'applied',
                                   order: 'applied'
                               },
                               customize: function (doc) {
                                   doc.content.splice(0, 1);
                                   var now = new Date();
                                   doc.pageMargins = [20, 70, 20, 30];
                                   doc.defaultStyle.fontSize = 8;
                                   doc.styles.tableHeader.fontSize = 8;
                                   doc.styles.tableFooter.fontSize = 8;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                       { text: $("#lnkTitle").text() + '\n' },
                                                      // { text: 'Type : ' + $('.ddlType option:selected').text() + "\n" },
                                                       { text: 'With History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + "\n" },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                   ],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   width: 70,
                                                   height: 45,
                                                   image: imagebase64
                                               }
                                           ],
                                           margin: 20
                                       }
                                   });
                                   doc['footer'] = (function (page, pages) {
                                       return {
                                           columns: [
                                              {
                                                  alignment: 'left',
                                                  fontSize: 8,
                                                  text: ['Created on: ', { text: jsDate.toString() }]
                                              },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['Version : ', { text: Version }]
                                                },
                                               {
                                                   alignment: 'right',
                                                   fontSize: 8,
                                                   text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                               }
                                           ],
                                           margin: 20
                                       }
                                   });

                                   var objLayout = {};
                                   objLayout['hLineWidth'] = function (i) { return .5; };
                                   objLayout['vLineWidth'] = function (i) { return .5; };
                                   objLayout['hLineColor'] = function (i) { return '#000'; };
                                   objLayout['vLineColor'] = function (i) { return '#000'; };
                                   objLayout['paddingLeft'] = function (i) { return 4; };
                                   objLayout['paddingRight'] = function (i) { return 4; };
                                   doc.content[0].layout = objLayout;
                                   var rowCount = doc.content[0].table.body.length;
                                   for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                       doc.content[0].table.body[i][0].alignment = 'center';
                                       doc.content[0].table.body[i][4].alignment = 'center';
                                       doc.content[0].table.body[i][6].alignment = 'center';

                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'center';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'center';
                               }
                           }]
                    });
                }
            }
        }
    </script>
    <style>
        .ui-widget {
            font-size: 12px;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }

        input.txtCompContri, input.txtDistContri {
            text-align: right;
        }

        td.txtSrNo {
            text-align: center;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyLeft {
            text-align: left;
        }

        .dtbodyRight {
            text-align: right;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

         th.table-header-gradient {
            z-index: 9;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .gvMissdata {
            font-size: 11px;
        }

        table.gvBrandChkHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        /*#tblBrandChk th, #tblBrandChk td {
            padding: 10px 5px;
        }*/
        .tableDiv table tbody th, .tableDiv table tbody td, .tableDiv table thead th, .tableDiv table thead td, .tableDiv table tfoot th, .tableDiv table tfoot td {
            padding: 5px !important;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />

    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">

                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="2" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="divViewDetail">
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">With History</label>
                            <asp:CheckBox runat="server" ID="chkIsHistory" TabIndex="3" CssClass="chkIsHistory form-control" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="4" />
                        &nbsp
                         <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" tabindex="5" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="6" />&nbsp&nbsp
                    </div>
                </div>
            </div>
            <div class="tableDiv">
                <input type="hidden" id="CountRowBrand" />
                <div id="divBrandChkEntry" class="divBrandChkEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                    <table id="tblBrandChk" class="table table-bordered" border="1" tabindex="7" style="font-size: 11px">
                        <thead>
                            <tr class="table-header-gradient">
                                <th class="dtbodyCenter" style="width: 2%; text-align: center;">Sr</th>
                                <th style="width: 3.5%">Edit</th>
                                <th style="width: 3.5%">Delete</th>
                                <th class="dtbodyLeft" style="width: 10%">Employee</th>
                                <th class="dtbodyLeft" style="width: 3%">Is Active</th>
                                <th class="dtbodyLeft" style="width: 6.5%;">Created By</th>
                                <th class="dtbodyCenter" style="width: 4.2%">Created Date/Time</th>
                                <th class="dtbodyLeft" style="width: 6.5%">Updated By</th>
                                <th class="dtbodyCenter" style="width: 4.2%">Updated Date/Time</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div id="divBrandChkReport" class="divBrandChkReport">
                    <table id="gvBrandChkHistory" class="gvBrandChkHistory table table-bordered nowrap" style="width: 100%; font-size: 11px;">
                        <thead>
                            <tr class="table-header-gradient">
                                <th class="dtbodyCenter">Sr</th>
                                <th class="dtbodyLeft dtTypeName">Employee</th>
                                <th class="dtbodyLeft">Status</th>
                                <%-- <th class="dtbodyLeft">Deleted</th>--%>
                                <th class="dtbodyLeft">Created By</th>
                                <th class="dtbodyCenter">Created Date/Time</th>
                                <th class="dtbodyLeft">Updated By</th>
                                <th class="dtbodyCenter">Updated Date/Time</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
