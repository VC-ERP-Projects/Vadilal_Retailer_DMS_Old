<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="UserUnitMappingMaster.aspx.cs" Inherits="Master_UserUnitMappingMaster" %>

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

        var availableParent = [];

        var Version = 'QA';
      //  var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var IpAddress;
        const JsonEmployee = [];
        const JsonDist = [];
        const JsonSS = [];
        $(document).ready(function () {

            $('#CountRowUserUnit').val(0);
            $('#tblUserUnitMap').DataTable().clear().destroy();
            ShowDistOrSS();
            ClearControls();

            $('#tblUserUnitMap').DataTable();

            // start Employee
            //// Start Search Employee

            $(document).on('keyup', '.AutoEmpName', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoEmpName' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'UserUnitMappingMaster.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strRegionId':'" + 0 + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (result) {
                                if (result.d == "") {
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
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoEmpName' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoEmpName' + col1).val(ui.item.value + " ");
                        $('#hdnEmpId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });


            //  $('#AutoEmpName' + indE).on('autocompleteselect', function (e, ui) {
            $('.AutoEmpName').on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoEmpName' + col1).val(ui.item.value);
                GetRegionEmpDetailsByDistSS(ui.item.value, col1);
            });

            // $('#AutoEmpName' + indE).on('change keyup', function () {
            $('.AutoEmpName').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoEmpName' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });

            //  $('#AutoEmpName' + indE).on('blur', function (e, ui) {
            $('.AutoEmpName').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoEmpName' + col1).val().trim() != "") {
                    if ($('#AutoEmpName' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee Name", 3);
                        $('#AutoEmpName' + col1).val("");
                        $('#hdnEmpId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpName' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + col1).val().trim(), "", col1, 1, "", $('#txtUnit' + col1).val());
                }
            });

            ////End Employee Textbox
            // end Employee
            // Start Distributor
            $(document).on('keyup', '.AutoDist', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();

                $('#AutoDist' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'UserUnitMappingMaster.aspx/SearchDistributor',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoDist' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoDist' + col1).val(ui.item.value + " ");
                        $('#hdnDistId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoDist').on('autocompleteselect', function (e, ui) {
                
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoDist' + col1).val(ui.item.value);
                GetRegionEmpDetailsByDistSS(ui.item.value, col1);
            });
            $('.AutoDist').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoDist' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });

            $('.AutoDist').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoDist' + col1).val().trim() != "") {
                    if ($('#AutoDist' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Distributor", 3);
                        $('#AutoDist' + col1).val("");
                        $('#hdnDistId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoDist' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData("", $('#AutoDist' + col1).val().trim(), col1, 2, "", $('#txtUnit' + col1).val());
                }
            });
            //End Distributor

            // Start SS TextBox
            $(document).on('keyup', '.AutoSS', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoSS' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'UserUnitMappingMaster.aspx/SearchSuperStockiest',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoDist' + col1),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoSS' + col1).val(ui.item.value + " ");
                        $('#hdnSSID' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            //$('#AutoSS' + indE).on('autocompleteselect', function (e, ui) {
            $('.AutoSS').on('autocompleteselect', function (e, ui) {

                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoDist' + col1).val(ui.item.value);
                GetRegionEmpDetailsByDistSS(ui.item.value, col1);
            });
            //  $('#AutoSS' + indE).on('change keyup', function () {
            $('.AutoSS').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoSS' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });

            //  $('#AutoSS' + indE).on('blur', function (e, ui) {
            $('.AutoSS').on('blur', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoSS' + col1).val().trim() != "") {
                    if ($('#AutoSS' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Super Stokiest", 3);
                        $('#AutoSS' + col1).val("");
                        $('#hdnSSID' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoSS' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData("", "", col1, 3, $('#AutoSS' + col1).val().trim(), $('#txtUnit' + col1).val());
                }
            });


            //  $("#tblUserUnitMap").tableHeadFixer('70vh');
            //  $("#gvUserUnitMapHistory").tableHeadFixer('75vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox,.txtUnit').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox,.txtUnit').prop('disabled', true);
                    $(this).val('Edit');
                }
            });

        });

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

        function CheckDuplicateData(pEmpCode, pDistCode, row3, ChkType, pSSCode, pUnit) {
            console.log('dup');
            var DistCode = "", EmpEmpCode = "", RSSCode = "";
            if (pEmpCode != "") {
                EmpEmpCode = pEmpCode.split("#")[2].trim();
            }

            if (pDistCode != "") {
                DistCode = pDistCode.split("#")[2].trim();
            }
            if (pSSCode != "") {
                RSSCode = pSSCode.split("#")[2].trim();
            }

            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            var option = $(".ddlOption").val();
            $('#tblUserUnitMap  > tbody > tr').each(function (row2, tr) {

                var EmpCode = "", DistCodeId = "", SSCode = "";
                if (option == 1) {
                    EmpCode = $("input[name='AutoEmpName']", this).val() != "" ? $("input[name='AutoEmpName']", this).val().split("#")[2].trim() : "";
                }
                else if (option == 2) {
                    console.log(row2);
                    DistCodeId = $("input[name='AutoDist']", this).val() != "" ? $("input[name='AutoDist']", this).val().split("#")[2].trim() : "";
                }
                else {
                    SSCode = $("input[name='AutoSS']", this).val() != "" ? $("input[name='AutoSS']", this).val().split("#")[2].trim() : "";
                }
                var LineNum = $("input[name='hdnLineNum']", this).val();
                var DistId = $("input[name='hdnDistId']", this).val();
                var EmpId = $("input[name='hdnEmpId']", this).val();
                var SSID = $("input[name='hdnSSID']", this).val();
                var Unit = $("input[name='txtUnit']", this).val() != "" ? $("input[name='txtUnit']", this).val() : "";

                if (ChkType == 4 && option == 1) {
                    if (EmpEmpCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && Unit == pUnit) {
                                cnt = 1;
                                errRow = row3;
                                $('#txtUnit' + row3).val("");
                                errormsg = 'Employee & Unit is already set for = ' + pEmpCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (option == 2) {
                    if (DistCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (DistCode == DistId) {
                                cnt = 1;
                                errRow = row3;
                                $('#txtUnit' + row3).val('');
                                errormsg = 'Distributor is already set for = ' + pDistCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                else {
                    if (SSID != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (SSID == RSSCode) {
                                cnt = 1;
                                errRow = row3;
                                $('#txtUnit' + row3).val('');
                                errormsg = 'Super Stockiest is already set for = ' + pSSCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                if (ChkType == 1) {
                    if (EmpEmpCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && Unit == pUnit) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoEmpName' + row3).val("");
                                $('#hdnEmpId' + row3).val(0);
                                errormsg = 'Employee is already set for = ' + pEmpCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 2) {
                    if (DistCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (DistCode == DistCodeId) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoDist' + row3).val('');
                                $('#hdnDistId' + row3).val(0);
                                errormsg = 'Distributor code is already set for = ' + pDistCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 3) {
                    if (SSID != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (SSID == RSSCode) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoSS' + row3).val('');
                                $('#hdnSSID' + row3).val(0);
                                errormsg = 'Super Stockiest code is already set for = ' + pSSCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                else {
                    if (pUnit != "") {
                        if (pUnit != "31" && pUnit != "37") {
                            cnt = 1;
                            errRow = row3;
                            $('#txtUnit' + row3).val('');
                            errormsg = 'Please enter only 31 or 37 unit ';
                            return false;
                        }
                    }
                }
                rowCnt_Claim++;
                //}
            });

            if (cnt == 1) {
                if (ChkType == 1) {
                    $('#AutoEmpName' + row3).val('');
                }
                else if (ChkType == 2) {
                    $('#AutoDist' + row3).val('');
                }
                else if (ChkType == 3) {
                    $('#AutoSS' + row3).val('');
                }
                ClearClaimRow(row3);
                ModelMsg(errormsg, 3);
                return false;
            }

            var indE = $('#CountRowUserUnit').val();
            if (indE == row3) {
                AddMoreRow();
            }
        }

        function ClearClaimRow(row) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblUserUnitMap > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var EmpCode = $("input[name='AutoEmpName']", this).val();
                if (EmpCode == "") {
                    // $(this).remove();
                }
                cnt++;
                rowCnt_Claim++;
            });

            if (cnt > 1) {
                var rowCnt_Claim = 1;
                $('#tblUserUnitMap > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var hdnEmpReasonId = $("input[name='hdnOCUMID']", this).val();
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        var DistCode = $("input[name='AutoDist']", this).val();
                        var SSCode = $("input[name='AutoSS']", this).val();
                        if (EmpName == "" && DistCode == "" && SSCode == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
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

            $('#tblUserUnitMap  > tbody').empty();
            var option = $(".ddlOption").val();
            var IsValid = true;
            $.ajax({
                url: 'UserUnitMappingMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ optionId: option }),
                async: false,
                success: function (result) {
                    $.unblockUI();
                    if (result.d == '') {
                        $.unblockUI();
                        event.preventDefault();
                        AddMoreRow();
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
                        var items = JSON.parse(result.d);
                        //console.log(items);
                        if (items.length > 0) {
                            $('#tblUserUnitMap  > tbody > tr').each(function (row2, tr) {
                                $(this).remove();
                            });
                            var trHTML = '';
                            var row4 = 1;
                            $('#CountRowUserUnit').val(0);
                            var indE = $('#CountRowUserUnit').val();
                            $('#CountRowUserUnit').val(indE);
                            var length = 0;
                            var itm = this;
                            // var table = $('#tblUserUnitMap').DataTable();

                            for (var i = 0; i < items.length; i++) {
                                row4 = $('#CountRowUserUnit').val();
                                //$('#chkEditEmp' + row4).click();
                                //  $('#chkEditEmp' + row4).prop("checked", false);
                                $('table#divUserUnitMap tr#NoROW').remove();  // Remove NO ROW
                                /// Add Dynamic Row to the existing Table
                                var indE = $('#CountRowUserUnit').val();
                                indE = parseInt(indE) + 1;
                                $('#CountRowUserUnit').val(indE);
                                var strEmp = "";
                                strEmp = "<tr id='trUserMap" + indE + "'>"
                                    + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + indE + "'>" + indE + "</td>"
                                    + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit ' checked='false'/>"
                                    + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                                    + "<td class='dtbodyCenter'><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indE + ");' /></td>"
                                    + "<td class='tdUser'><input type='text' id='AutoEmpName" + indE + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search ' value='" + items[i].EmpName + "' disabled='false' /></td>"
                                    + "<td class='tdDist'><input type='text' id='AutoDist" + indE + "' name='AutoDist' onchange='ChangeData(this);' class='form-control search AutoDist' value='" + items[i].DistName + "' disabled='false' /></td>"
                                    + "<td class='tdss'><input type='text' id='AutoSS" + indE + "' name='AutoSS' onchange='ChangeData(this);' class='form-control search ' value='" + items[i].SSName + "' disabled='false' /></td>"
                                    + "<td id='tdRegion" + indE + "' class='tdRegion'>" + items[i].Region + "</td>"
                                    + "<td id='tdBeatEmp" + indE + "' class='tdBeatEmp'>" + items[i].BeatEmp + "</td>"
                                    + "<td class='dtbodyRight'><input type='text' id='txtUnit" + indE + "' name='txtUnit' onchange='ChangeData(this);' maxlength='3' onkeypress='return isNumber(event)' class='form-control txtUnit' value='" + items[i].Unit + "'  disabled='false'/></td>"
                                    + "<td class='dtbodyCenter'><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox' disabled='false' /></td>"
                                    //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'>" + items[i].CreatedBy + "</td>"
                                    //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'>" + items[i].CreatedDate + "</td>"
                                    + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate dtbodyCenter'>" + items[i].UpdatedDate + "</td>"
                                    + "<input type='hidden' class='hdnDistId' id='hdnDistId" + indE + "' name='hdnDistId' value='" + items[i].CustID + "'/></td>"
                                    + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + indE + "' name='hdnEmpId' value='" + items[i].CustID + "'/></td>"
                                    + "<input type='hidden' class='hdnSSID' id='hdnSSID" + indE + "' name='hdnSSID' value='" + items[i].CustID + "'/></td>"
                                    + "<input type='hidden' class='hdnOCUMID' id='hdnOCUMID" + indE + "' name='hdnOCUMID' value='" + items[i].OCUMID + "' /></td>"
                                    + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                                    + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";
                                $('#tblUserUnitMap > tbody').append(strEmp);
                                //  ShowDistOrSS();
                                $('#trUserMap' + indE).find('#chkIsActive' + indE).prop("checked", items[i].Active);

                                // $('.chkEdit').hide();
                                ////  $('.chkEdit').prop("checked", true);
                                  $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);




                                $('#txtUnit' + indE).on('change keyup', function () {
                                    var currentRow = $(this).closest("tr");
                                    var col1 = currentRow.find("td:eq(0)").text();
                                    if ($('#txtUnit' + col1).val() == "") {
                                        ClearClaimRow(col1);
                                    }
                                });
                                $('#txtUnit' + indE).on('blur', function (e, ui) {
                                    if ($('#txtUnit' + indE).val().trim() != "") {
                                        var currentRow = $(this).closest("tr");
                                        var col1 = currentRow.find("td:eq(0)").text();

                                        if ($('#txtUnit' + col1).val() == "" || $('#txtUnit' + col1).val() == "0") {
                                            ModelMsg("Select Proper Unit", 3);
                                            $('#txtUnit' + col1).val("");
                                            return;
                                        }
                                        var txt = $('#txtUnit' + col1).val();
                                        if (txt == "undefined" || txt == "") {
                                            //ModelMsg("Enter Item Code Or Name", 3);
                                            return false;
                                        }
                                        var lineNum = 1;
                                        $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                                            $(".txtSrNo", this).text(lineNum);
                                            lineNum++;
                                        });
                                        var option = $(".ddlOption").val();
                                        if (option == 1) {
                                            CheckDuplicateData($('#AutoEmpName' + col1).val(), "", col1, 4, "", $('#txtUnit' + col1).val());
                                        }
                                        else if (option == 2) {
                                            CheckDuplicateData("", $('#AutoDist' + col1).val(), col1, 4, "", $('#txtUnit' + col1).val());
                                        }
                                        else {
                                            CheckDuplicateData("", "", col1, 4, $('#AutoSS' + col1).val(), $('#txtUnit' + col1).val());
                                        }

                                    }
                                });
                            }
                        }
                        else {
                            $('#tblUserUnitMap  > tbody > tr').each(function (row2, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                        }
                    }
                    AddMoreRow();
                },
                scroller: {
                    loadingIndicator: true
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });

        }
        function ClearControls() {
            $('.divUserUnitMap').attr('style', 'display:none;');
            $('.divUserUnitMapReport').attr('style', 'display:none;');

            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblUserUnitMap tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvUserUnitMapHistory')) {
                $('.gvUserUnitMapHistory').DataTable().destroy();
            }
            //if ($.fn.DataTable.isDataTable('.tblUserUnitMap')) {
            //    $('.tblUserUnitMap').DataTable().destroy();
            //}
            var option = $(".ddlOption").val();
            $('.gvUserUnitMapHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divUserUnitMapReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
                $('.divClaimReport').removeAttr('style');
                $('.divViewDetail').removeAttr('style');


                if (option == 1) {
                    $('.tdss').hide();
                    $('.thss').hide();
                    $('.tdDist').hide();
                    $('.thDist').hide();
                    $('.thUser').show();
                    $('.tdUser').show();
                    $('.thBeatEmp').hide();
                    $('.tdBeatEmp').hide();
                }
                else if (option == 2) {
                    $('.tdss').hide();
                    $('.thss').hide();
                    $('.tdDist').show();
                    $('.thDist').show();
                    $('.thUser').hide();
                    $('.tdUser').hide();
                    $('.thBeatEmp').show();
                    $('.tdBeatEmp').show();
                }
                else {
                    $('.tdss').show();
                    $('.thss').show();
                    $('.tdDist').hide();
                    $('.thDist').hide();
                    $('.thUser').hide();
                    $('.tdUser').hide();
                    $('.thBeatEmp').show();
                    $('.tdBeatEmp').show();
                }
            }
            else {
                $('.divUserUnitMap').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowUserUnit').val(0);
                //  $('#tblUserUnitMap').DataTable().clear().destroy();
                $('#tblUserUnitMap').DataTable().clear().destroy();
                FillData();
                var option = $(".ddlOption").val();
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "20px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "35px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 4 });
                if (option == 1) {
                    aryJSONColTable.push({ "width": "100px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 8 });
                }
                else {
                    aryJSONColTable.push({ "width": "250px", "sClass": "dtbodyLeft", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyLeft", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "92px", "sClass": "dtbodyCenter", "aTargets": 11 });
                }

                $('#tblUserUnitMap').DataTable({
                    bFilter: false,
                    scrollCollapse: true,
                    "sExtends": "collection",
                    scrollX: true,
                    scrollY: '67vh',
                    responsive: true,
                    "bPaginate": false,
                    "autoWidth": false,
                    "bDestroy": true,
                    scroller: false,
                    deferRender: true,
                    "aoColumnDefs": aryJSONColTable,
                    "bProcessing": true,
                    info: true,
                    "stateSave": true,
                    "bLengthChange": false,
                });

                //setTimeout(function () {

                //}, 200)
            }
        }
        function RemoveClaimLockingRow(row) {

            var DiscountExcId = $('table#tblUserUnitMap tr#trUserMap' + row).find(".hdnOCUMID").val();
            $('table#tblUserUnitMap tr#trUserMap' + row).find(".IsChange").val("1");
            $('table#tblUserUnitMap tr#trUserMap' + row).remove();
            $('table#tblUserUnitMap tr#trUserMap' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblUserUnitMap tr#trUserMap' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }
        function AddMoreRow() {
            $('table#tblUserUnitMap tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var indE = $('#CountRowUserUnit').val();

            indE = parseInt(indE) + 1;
            $('#CountRowUserUnit').val(indE);

            var strEmp = "";
            strEmp = "<tr id='trUserMap" + indE + "'>"
                + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + indE + "'>" + indE + "</td>"
                + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td class='dtbodyCenter'><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indE + ");' /></td>"
                + "<td class='tdUser'><input type='text' id='AutoEmpName" + indE + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search AutoEmpName' /></td>"
                + "<td class='tdDist'><input type='text' id='AutoDist" + indE + "' name='AutoDist' onchange='ChangeData(this);' class='form-control search AutoDist' /></td>"
                + "<td class='tdss'><input type='text' id='AutoSS" + indE + "' name='AutoSS' onchange='ChangeData(this);' class='form-control search AutoSS' /></td>"
                + "<td id='tdRegion" + indE + "' class='tdRegion'></td>"
                + "<td id='tdBeatEmp" + indE + "' class='tdBeatEmp'></td>"
                + "<td class='dtbodyCenter'><input type='text' id='txtUnit" + indE + "' name='txtUnit' onchange='ChangeData(this);' maxlength='3' onkeypress='return isNumber(event)' class='form-control txtUnit'/></td>"
                + "<td class='dtbodyCenter'><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"

                //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'></td>"
                //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'></td>"

                + "<input type='hidden' class='hdnOCUMID' id='hdnOCUMID" + indE + "' name='hdnOCUMID'/></td>"
                + "<input type='hidden' class='hdnDistId' id='hdnDistId" + indE + "' name='hdnDistId'  /></td>"
                + "<input type='hidden' class='hdnSSID' id='hdnSSID" + indE + "' name='hdnSSID'  /></td>"
                + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + indE + "' name='hdnEmpId'  /></td>"
                + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";

            $('#tblUserUnitMap > tbody').append(strEmp);
            $('#tblUserUnitMap tbody tr:last-child td:first-child').click();
            //$('#tblUserUnitMap tr:last').focus();
            ShowDistOrSS();
            $('.chkEdit').hide();
            //  $('.chkEdit').prop("checked", true);
            var table = document.getElementById("tblUserUnitMap");

            //Start Employee  Textbox

            $('#AutoEmpName' + indE).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'UserUnitMappingMaster.aspx/SearchEmployee',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strRegionId':'" + 0 + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (result) {
                            if (result.d == "") {
                                return false;
                            }
                            //else if (result.d[0].indexOf("ERROR=") >= 0) {
                            //    var ErrorMsg = result.d[0].split('=')[1].trim();
                            //    ModelMsg(ErrorMsg, 3);
                            //    return false;
                            //}
                            else {
                                response(result.d[0]);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                position: { collision: "flip" },
                select: function (event, ui) {
                    $('#hdnEmpId' + indE).val(ui.item.value.split('#')[2].trim());
                    $('#AutoEmpName' + indE).val(ui.item.value + " ");
                },
                change: function (event, ui) {
                    if (!ui.item) {
                    }
                },
                minLength: 1
            });
            $('#AutoEmpName' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoEmpName' + indE).val(ui.item.value);
                GetRegionEmpDetailsByDistSS(ui.item.value, indE);
            });

            $('#AutoEmpName' + indE).on('change keyup', function () {
                if ($('#AutoEmpName' + indE).val() == "") {
                    ClearClaimRow(indE);
                }
            });

            $('#AutoEmpName' + indE).on('blur', function (e, ui) {
                if ($('#AutoEmpName' + indE).val().trim() != "") {
                    if ($('#AutoEmpName' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee Name", 3);
                        $('#AutoEmpName' + indE).val("");
                        $('#hdnEmpId' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpName' + indE).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + indE).val().trim(), "", indE, 1, "", $('#txtUnit' + indE).val().trim());
                }
            });

            //End Employee Textbox

            //Start Distributor Textbox           
            $('#AutoDist' + indE).keyup(function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoDist' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'UserUnitMappingMaster.aspx/SearchDistributor',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoDist' + col1).val(ui.item.value + " ");
                        $('#hdnDistId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('#AutoDist' + indE).autocomplete({
                source: JsonDist,
                position: { collision: "flip" },
                select: function (event, ui) {
                    $('#hdnDistId' + indE).val(ui.item.value.split('#')[2].trim());
                    $('#AutoDist' + indE).val(ui.item.value + " ");
                    //   $('#hdnDistId' + indE).val(ui.item.value.split("#")[2].trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                    }
                },
                minLength: 1
            });

            $('#AutoDist' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoDist' + indE).val(ui.item.value);
                GetRegionEmpDetailsByDistSS(ui.item.value, indE);
            });

            $('#AutoDist' + indE).on('change keyup', function () {
                if ($('#AutoDist' + indE).val() == "") {

                    ClearClaimRow(indE);
                    // $('#hdnDistId' + indE).val(0);

                }
            });

            $('#AutoDist' + indE).on('blur', function (e, ui) {
                if ($('#AutoDist' + indE).val().trim() != "") {

                    if ($('#AutoDist' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Distributor", 3);
                        $('#AutoDist' + indE).val("");
                        $('#hdnDistId' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoDist' + indE).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData("", $('#AutoDist' + indE).val().trim(), indE, 2, "", $('#txtUnit' + indE).val().trim());
                }
            });
            //End Distributor textbox

            //Start SS Textbox           
            $('#AutoSS' + indE).keyup(function () {
              
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoSS' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'UserUnitMappingMaster.aspx/SearchSuperStockiest',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                console.log(data.d);
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    select: function (event, ui) {
                        var currentRow = $(this).closest("tr");
                        var col1 = currentRow.find("td:eq(0)").text();
                        $('#AutoSS' + col1).val(ui.item.value + " ");
                        $('#hdnSSID' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('#AutoSS' + indE).autocomplete({
                source: function (request, response) {
                   
                    $.ajax({
                        type: "POST",
                        url: 'UserUnitMappingMaster.aspx/SearchSuperStockiest',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                return {
                                    label: item.Text,
                                    value: item.Text,
                                    id: item.Value
                                };
                            }))
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                position: { collision: "flip" },
                select: function (event, ui) {
                    $('#hdnSSID' + indE).val(ui.item.value.split('#')[2].trim());
                    $('#AutoSS' + indE).val(ui.item.value + " ");
                    //   $('#hdnDistId' + indE).val(ui.item.value.split("#")[2].trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                    }
                },
                minLength: 1
            });

            $('#AutoSS' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoSS' + indE).val(ui.item.value);
                GetRegionEmpDetailsByDistSS(ui.item.value, indE);
            });

            $('#AutoSS' + indE).on('change keyup', function () {
                if ($('#AutoSS' + indE).val() == "") {

                    ClearClaimRow(indE);
                    // $('#hdnDistId' + indE).val(0);

                }
            });

            $('#AutoSS' + indE).on('blur', function (e, ui) {
                if ($('#AutoSS' + indE).val().trim() != "") {

                    if ($('#AutoSS' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Super Stockiest", 3);
                        $('#AutoSS' + indE).val("");
                        $('#hdnSSID' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoSS' + indE).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData("", "", indE, 3, $('#AutoSS' + indE).val().trim(), $('#txtUnit' + indE).val().trim());
                }
            });
            //End Distributor textbox

            $('#txtUnit' + indE).on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#txtUnit' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });
            $('#txtUnit' + indE).on('blur', function (e, ui) {
                if ($('#txtUnit' + indE).val().trim() != "") {
                    var currentRow = $(this).closest("tr");
                    var col1 = currentRow.find("td:eq(0)").text();

                    if ($('#txtUnit' + col1).val() == "" || $('#txtUnit' + col1).val() == "0") {
                        ModelMsg("Select Proper Unit", 3);
                        $('#txtUnit' + col1).val("");
                        return;
                    }
                    var txt = $('#txtUnit' + col1).val();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblUserUnitMap > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    var option = $(".ddlOption").val();
                    if (option == 1) {
                        CheckDuplicateData($('#AutoEmpName' + col1).val(), "", col1, 4, "", $('#txtUnit' + col1).val());
                    }
                    else if (option == 2) {
                        CheckDuplicateData("", $('#AutoDist' + col1).val(), col1, 4, "", $('#txtUnit' + col1).val());
                    }
                    else {
                        CheckDuplicateData("", "", col1, 4, $('#AutoSS' + col1).val(), $('#txtUnit' + col1).val());
                    }

                }
            });
        }
        function Cancel() {
            window.location = "../Master/UserUnitMappingMaster.aspx";
        }
        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowUserUnit').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
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

            var TableData_Claim = [];
            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Claim = 0;


            if (!IsValid) {
                $.unblockUI();
                return false;
            }
            var option = $(".ddlOption").val();
            $('#tblUserUnitMap  > tbody > tr').each(function (row, tr) {
                var EmpName = "", Unit = 0;
                if (option == 1) {
                    EmpName = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();
                    Unit = $("input[name='txtUnit']", this).val();
                    var IsDeleted = $('#hdnIsRowDeleted').val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    if (EmpName != "" && (Unit == '' || Unit == 0)) {
                        $.unblockUI();
                        ModelMsg("Please enter unit at row : " + (parseInt(row) + 1), 3);
                        return false;
                    }
                    if ((EmpName != "" && Unit != "") && (IsChange == "1" || IsDeleted == 1)) {
                        totalItemcnt = 1;
                        var OCUMID = $("input[name='hdnOCUMID']", this).val().trim();
                        var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                        // var hdnDistId = $("input[name='hdnDistId']", this).val().trim();
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IPAddress = $("#hdnIPAdd").val();
                        var IsChange = $("input[name='IsChange']", this).val().trim();
                        var obj = {
                            OCUMID: OCUMID,
                            CustId: EmpId,
                            Unit: Unit,
                            Active: IsActive,
                            IPAddress: IPAddress,
                            IsChange: IsChange
                        };
                        TableData_Claim.push(obj);
                        rowCnt_Claim++;
                    }
                }
                else if (option == 2) {
                    DistName = $("input[name='AutoDist']", this).val().split('#').pop().trim();
                    Unit = $("input[name='txtUnit']", this).val();
                    var IsDeleted = $('#hdnIsRowDeleted').val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    if (DistName != "" && (Unit == '' || Unit == 0)) {
                        $.unblockUI();
                        ModelMsg("Please enter unit at row : " + (parseInt(row) + 1), 3);
                        return false;
                    }
                    if ((DistName != "" && Unit != "") && (IsChange == "1" || IsDeleted == 1)) {
                        totalItemcnt = 1;
                        var OCUMID = $("input[name='hdnOCUMID']", this).val().trim();
                        var DistId = $("input[name='hdnDistId']", this).val().trim();
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IPAddress = $("#hdnIPAdd").val();
                        var IsChange = $("input[name='IsChange']", this).val().trim();
                        var obj = {
                            OCUMID: OCUMID,
                            CustId: DistId,
                            Unit: Unit,
                            Active: IsActive,
                            IPAddress: IPAddress,
                            IsChange: IsChange
                        };
                        TableData_Claim.push(obj);
                        rowCnt_Claim++;
                    }
                }
                else {
                    SSName = $("input[name='AutoSS']", this).val().split('#').pop().trim();
                    Unit = $("input[name='txtUnit']", this).val();
                    var IsDeleted = $('#hdnIsRowDeleted').val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    if (SSName != "" && (Unit == '' || Unit == 0)) {
                        $.unblockUI();
                        ModelMsg("Please enter unit at row : " + (parseInt(row) + 1), 3);
                        return false;
                    }
                    if ((SSName != "" && Unit != "") && (IsChange == "1" || IsDeleted == 1)) {
                        totalItemcnt = 1;
                        var OCUMID = $("input[name='hdnOCUMID']", this).val().trim();
                        var SSId = $("input[name='hdnSSID']", this).val().trim();
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IPAddress = $("#hdnIPAdd").val();
                        var IsChange = $("input[name='IsChange']", this).val().trim();
                        var obj = {
                            OCUMID: OCUMID,
                            CustId: SSId,
                            Unit: Unit,
                            Active: IsActive,
                            IPAddress: IPAddress,
                            IsChange: IsChange
                        };
                        TableData_Claim.push(obj);
                        rowCnt_Claim++;
                    }

                }

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
            var UserUnitMappingData = JSON.stringify(TableData_Claim);
            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'UserUnitMappingMaster.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputUnitMapping: UserUnitMappingData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val(), OptionId: option }),
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
                        // ModelMsg(SuccessMsg, 3);
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

        function ShowDistOrSSOnChange() {
            var option = $(".ddlOption").val();
            if (option == 1) {
                $('#tblUserUnitMap').find('th:nth-child(4)').hide();
                $('#tblUserUnitMap').find('th:nth-child(5)').hide();
                $('#tblUserUnitMap').find('th:nth-child(8)').hide();
                $('.tdDist').hide();
                $('.tdss').hide();
                // $('.thBeatEmp').hide();
                $('.tdBeatEmp').hide();
                ClearClaimRow();
                $('#tblUserUnitMap').find('th:nth-child(3)').show();
                $('.tdUser').show();
                //$('#tblUserUnitMap').find('th:nth-child(4)').show();
                //$('.tdRegion').show();

            }
            else if (option == 2) {
                $('#tblUserUnitMap').find('th:nth-child(4)').hide();
                $('.tdss').hide();
                $('#tblUserUnitMap').find('th:nth-child(6)').hide();
                $('.tdUser').hide();
                ClearClaimRow();
                $('#tblUserUnitMap').find('th:nth-child(5)').show();
                $('#tblUserUnitMap').find('th:nth-child(8)').show();
                $('.tdDist').show();
                $('.tdBeatEmp').show();

            }
            else if (option == 3) {
                $('#tblUserUnitMap').find('th:nth-child(5)').hide();
                $('#tblUserUnitMap').find('th:nth-child(4)').hide();
                $('.tdUser').hide();
                $('.tdDist').hide();
                //$('#tblUserUnitMap').find('th:nth-child(4)').hide();
                //$('.tdRegion').hide();
                ClearClaimRow();
                $('#tblUserUnitMap').find('th:nth-child(6)').show();
                $('#tblUserUnitMap').find('th:nth-child(8)').show();
                $('.tdss').show();
                // $('.thBeatEmp').show();
                $('.tdBeatEmp').show();
            }
            else {
                //$('#tblUserUnitMap').find('th:nth-child(7)').hide();
                //$('.tdss').hide();
                //ClearClaimRow();
            }
            ClearControls();
            $('#hdnDeleteIDs').val('');
            $('#hdnIsRowDeleted').val("0");

        }
        function ShowDistOrSS() {
            console.log(1);
            var option = $(".ddlOption").val();
            if (option == 1) {
                //$('#tblUserUnitMap').find('th:nth-child(5)').hide();
                //$('#tblUserUnitMap').find('th:nth-child(4)').hide();
                $('.tdDist').hide();
                $('.tdss').hide();
                $('.thDist').hide();
                $('.thss').hide();
                $('.thBeatEmp').hide();
                $('.tdBeatEmp').hide();
                ClearClaimRow();
                // $('#tblUserUnitMap').find('th:nth-child(3)').show();
                $('.tdUser').show();
                $('.thUser').show();
                //$('#tblUserUnitMap').find('th:nth-child(4)').show();
                //$('.tdRegion').show();

            }
            else if (option == 2) {
                // $('#tblUserUnitMap').find('th:nth-child(6)').hide();
                $('.tdss').hide();
                $('.thss').hide();
                //$('#tblUserUnitMap').find('th:nth-child(5)').hide();
                $('.tdUser').hide();
                $('.thUser').hide();
                ClearClaimRow();
                //$('#tblUserUnitMap').find('th:nth-child(4)').show();
                $('.tdDist').show();
                $('.thDist').show();
                $('.thBeatEmp').show();
                $('.tdBeatEmp').show();
                //$('#tblUserUnitMap').find('th:nth-child(4)').show();
                //$('.tdRegion').show();

            }
            else if (option == 3) {
                //$('#tblUserUnitMap').find('th:nth-child(4)').hide();
                //$('#tblUserUnitMap').find('th:nth-child(5)').hide();
                $('.tdDist').hide();
                $('.thDist').hide();
                $('.tdUser').hide();
                $('.thUser').hide();
                ClearClaimRow();
                //  $('#tblUserUnitMap').find('th:nth-child(6)').show();
                $('.tdss').show();
                $('.thss').show();
                $('.thBeatEmp').show();
                $('.tdBeatEmp').show();
            }
            else {
                //$('#tblUserUnitMap').find('th:nth-child(7)').hide();
                //$('.tdss').hide();
                //ClearClaimRow();
            }

        }
        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();
                var option = $(".ddlOption").val();
                $('.gvUserUnitMapHistory tbody').empty();
                $.ajax({
                    url: 'UserUnitMappingMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','optionId': '" + option + "'}",
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
                            var k = 1;
                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + k + "</td>"
                                    + "<td class='tdUser'>" + ReportData[i].EmpName + "</td>"
                                    + "<td class='tdDist'>" + ReportData[i].DistName + "</td>"
                                    + "<td class='tdss'>" + ReportData[i].SSName + "</td>"
                                    + "<td class='tdRegion'>" + ReportData[i].Region + "</td>"
                                    + "<td class='tdBeatEmp'>" + ReportData[i].BeatEmp + "</td>"
                                    + "<td>" + ReportData[i].Unit + "</td>"
                                    + "<td>" + ReportData[i].IsActive + "</td>"
                                    + "<td>" + ReportData[i].IsDeleted + "</td>"
                                    //+ "<td>" + ReportData[i].CreatedBy + "</td>"
                                    //+ "<td>" + ReportData[i].CreatedDate + "</td>"
                                    + "<td class='tdUpdateBy'>" + ReportData[i].UpdatedBy + "</td>"
                                    + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"
                                //+ "<td>" + ReportData[i].Employee + "</td>
                                k = k + 1;
                                $('.gvUserUnitMapHistory > tbody').append(str);
                                //var option = $(".ddlOption").val();
                                //console.log(option);

                            }
                            if (option == 1) {
                                $('.tdDist').hide();
                                $('.tdss').hide();
                                $('.thDist').hide();
                                $('.thss').hide();
                                $('.tdUser').show();
                                $('.thUser').show();

                                $('.tdBeatEmp').hide();
                                $('.thBeatEmp').hide();
                            }
                            else if (option == 2) {
                                $('.tdss').hide();
                                $('.thss').hide();
                                $('.tdUser').hide();
                                $('.thUser').hide();
                                $('.tdDist').show();
                                $('.thDist').show();
                                $('.tdBeatEmp').show();
                                $('.thBeatEmp').show();
                            }
                            else if (option == 3) {
                                $('.tdDist').hide();
                                $('.thDist').hide();
                                $('.tdUser').hide();
                                $('.thUser').hide();
                                $('.tdss').show();
                                $('.thss').show();
                                $('.tdBeatEmp').show();
                                $('.thBeatEmp').show();
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvUserUnitMapHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });
                    var option = $(".ddlOption").val();
                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "7px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyLeft", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyRight", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyLeft", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 10 });


                    $('.gvUserUnitMapHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '60vh',
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
                                data += 'Option,' + $('.ddlOption option:selected').text() + '\n';
                                data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + jsDate.toString() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                columns: ':visible',
                                search: 'applied',
                                order: 'applied',
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
                            extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '_' + new Date().toLocaleTimeString('en-US'),
                            exportOptions: {
                                columns: ':visible',
                                search: 'applied',
                                order: 'applied'
                            },
                            customize: function (xlsx) {

                                sheet = ExportXLS(xlsx, 6);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                var r3 = Addrow(3, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                var r4 = Addrow(4, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r5 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'portrait', //portrait
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
                                doc.defaultStyle.fontSize = 6;
                                doc.styles.tableHeader.fontSize = 8;
                                doc.styles.tableFooter.fontSize = 6;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: false,
                                                text: [
                                                    { text: $("#lnkTitle").text() + '\n' },
                                                    { text: 'Option : ' + $('.ddlOption option:selected').text() + "\n" },
                                                    { text: 'With History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + "\n" },
                                                    //{ text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                    //{ text: 'Created On : ' + jsDate.toString() + "\n" },
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
                                            //{
                                            //    alignment: 'right',
                                            //    fontSize: 8,
                                            //    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                            //},
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['Version : ', { text: Version }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                            }
                                        ],
                                        margin: 20
                                    }
                                });
                                var option = $(".ddlOption").val();
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
                                    if (option != 1) {
                                        doc.content[0].table.body[i][6].alignment = 'left';
                                        doc.content[0].table.body[i][7].alignment = 'center';
                                        // doc.content[0].table.body[0][8].alignment = 'left';
                                    }
                                    else {
                                        doc.content[0].table.body[i][6].alignment = 'center';
                                    }
                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'left';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'left';

                                if (option != 1) {
                                    doc.content[0].table.body[0][6].alignment = 'left';
                                    doc.content[0].table.body[0][7].alignment = 'center';
                                    // doc.content[0].table.body[0][8].alignment = 'left';
                                }
                                else {
                                    doc.content[0].table.body[0][6].alignment = 'center';
                                }

                            }
                        }]
                    });
                }
            }
        }
        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            if (charCode > 31 && (charCode < 48 || charCode > 57)) {
                return false;
            }

            return true;
        }
        function GetRegionEmpDetailsByDistSS(CustId, row) {
            var option = $(".ddlOption").val();
            var Region = "", BeatEmp = "";
            var CustomerId = CustId.split("#")[2].trim();
            //if (option == 1) {   
            //    CustId = CustId.split("#")[2].trim();
            //}
            //else if (option == 2) {
            //    CustId = itemCode.split("-")[0].trim();
            //}
            //else if (option == 3) {
            //    CustId = itemCode.split("-")[0].trim();
            //}


            $.ajax({
                url: 'UserUnitMappingMaster.aspx/GetCustomerEmpDetails',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ CustomerId: CustomerId, optionId: option }),

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
                        var units = JSON.parse(result.d);
                        console.log(units[0].BeatEmp);
                        $('#tdRegion' + row).text(units[0].Region);
                        $('#tdBeatEmp' + row).text(units[0].BeatEmp);

                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
    </script>
    <style>
        /*.container {
            width:100% !important;
        }*/
        .full-width {
    width: 100vw;
    position: relative;
    left: 50%;
    right: 50%;
    margin-left: -50vw;
    margin-right: -50vw;
}
        @media (min-width: 768px){
  .container{
    max-width:100%;
  }  
}
         @media (min-width: 1200px) {
            .container {
                width: 1430px;
            }
        }
@media (min-width: 992px){
  .container{
    max-width:100%;
  }
}
        @media (min-width: 1200px) {
            .dataTables_scrollHead {
                width: 1285px !important;
            }
            .dataTables_scrollBody {
              width: 1285px !important;
            }
        }
        .table > tfoot {
            /*position: -webkit-sticky;*/
            position: sticky;
            bottom: 0;
            z-index: 4;
            /*inset-block-end: 0;*/
        }

        .chkEdit {
            display: none;
        }

        
        table.dataTable thead .sorting,
        table.dataTable thead .sorting_asc,
        table.dataTable thead .sorting_desc {
            background: none;
        }

        .body {
            overflow: hidden !important;
            overflow-x: hidden !important;
        }

        .chkIsActive {
        }


        /*.dataTables_scrollHead {
            width: 1463px !important;
            overflow: hidden !important;
            position: relative !important;
            border: 0px !important;
        }*/

        /*.dataTables_scrollBody {
            position: relative !important;
            overflow: auto !important;
            width: 1463px !important;
        }*/

        /*table.dataTable tbody th, table.dataTable tbody td {
            padding: 2px 5px !important;
        }*/

        /*.table > thead > tr > th, .table > tbody > tr > th,*/
        /*.table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 2px 5px !important;
        }*/
        table.dataTable tbody th, table.dataTable tbody td {
            padding: 2px 5px !important;
        }

        table.tblUserUnitMap.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100vw !important;
            margin: 0;
            table-layout: auto;
            
        }

        table#tblUserUnitMap {
            width: 100vw;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblUserUnitMap tbody {
                width: 100vw;
                height: 30%;
            }
            table#tblUserUnitMap tbody tr {
            position: relative;
            }
            table#tblUserUnitMap thead tr {
                position: relative;
            }

            table#tblUserUnitMap tfoot tr {
                position: relative;
                width: 100vw;
            }

            table#tblUserUnitMap tbody tr td {
                padding: 3px !important;
                width: 100vw;
                vertical-align: middle !important;
            }

           

        .row {
            margin-right: -15px;
            margin-left: -15px;
            margin-bottom: 0px !important;
        }

        .ui-widget {
            font-size: 10px;
        }

        .ui-datepicker {
            z-index: 9 !important;
        }

        .search {
            font-size: 10px !important;
            height: 22px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }


        .ui-autocomplete {
            position: absolute;
        }

        table#tblUserUnitMap.dataTable tbody th {
            padding-left: 6px !important;
        }

        table#tblUserUnitMap.dataTable tbody th {
            padding-left: 6px !important;
        }



        .dtbodyCenter {
            /*text-align: center;*/
            text-align: -webkit-center !important;
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

        .dataTables_scrollHeadInner {
            width: auto;
        }

        table.dataTable tbody th {
            text-align: left;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
            position: relative;
        }

        th.table-header-gradient {
            z-index: 9;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        #tblUserUnitMap {
            margin-top: 0px !important;
        }


        .txtUnit {
            font-size: 10px !important;
            height: 22px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
            text-align: right !important;
        }

        .tdUpdateBy, .tdBeatEmp, .tdRegion {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
        }

            .tdUpdateBy::-webkit-scrollbar {
                display: none;
            }

            .tdBeatEmp::-webkit-scrollbar {
                display: none;
            }

            .tdRegion::-webkit-scrollbar {
                display: none;
            }
        /*table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td::-webkit-scrollbar {
                display: none;
            }*/

        /* Hide scrollbar for IE, Edge and Firefox */
        .tdUpdateBy, .tdBeatEmp, .tdRegion {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        dataTables_scroll .dataTables_scrollBody {
            overflow-y: auto !important;
            overflow-x: hidden !important;
            max-height: none !important;
        }

        .dataTables_wrapper .dataTables_scroll {
            clear: both;
            width: 100%;
            /*height: 60vh;*/
        }

        .dataTables_scrollHeadInner {
            width: 100% !important;
        }

        .element::-webkit-scrollbar {
            width: 0 !important;
        }

        .element {
            overflow: -moz-scrollbars-none;
        }

        .element {
            -ms-overflow-style: none;
        }
      
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />
    <div class="container">
    <div class="panel panel-default">
        <div class="panel-body" style="height: 560px !important;">
            <div class="row _masterForm">
                <div class="col-lg-12">
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Option</label>
                            <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="1" onchange="ShowDistOrSSOnChange();">
                                <asp:ListItem Value="1">Back-Office User</asp:ListItem>
                                <asp:ListItem Value="2" Selected="True">Distributor</asp:ListItem>
                                <asp:ListItem Value="3">Super Stockist</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">View Report</label>
                            <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="3" onchange="ClearControls();" />
                        </div>
                    </div>
                    <div class="divViewDetail">
                        <div class="col-lg-2">
                            <div class="input-group form-group">
                                <label class="input-group-addon">With History</label>
                                <asp:CheckBox runat="server" ID="chkIsHistory" TabIndex="4" CssClass="chkIsHistory form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                            <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" tabindex="5" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" />
                            <input type="button" id="btnSearch" name="btnSearch" value="Process" tabindex="6" class="btnSearch btn btn-default" onclick="GetReport();" />
                            &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" tabindex="7" onclick="Cancel()" class="btn btn-default" />
                        </div>
                    </div>
                    <div class="col-lg-3">
                    </div>
                </div>
            </div>
            <div class="row ">
                <div class="col-lg-12 col-md-12 col-sm-12">
                    <input type="hidden" id="CountRowUserUnit" />
                    <div id="divUserUnitMap" class="divUserUnitMap" runat="server" style="max-height: 70vh; position: absolute;">
                        <table id="tblUserUnitMap" class="table table-bordered" border="1" tabindex="8" style="border-collapse: collapse; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="width: 3%; text-align: center;">Sr</th>
                                    <th style="text-align: center; width: 4%;">Edit</th>
                                    <th style="width: 5%; text-align: center;">Delete</th>
                                    <th style="width: 15%; padding-left: 10px !important;" class="thUser">User</th>
                                    <th style="width: 15%; padding-left: 10px !important;" class="thDist">Distributor</th>
                                    <th style="width: 15%; padding-left: 10px !important;" class="thss">Super Stokiest</th>
                                    <th style="width: 10%; padding-left: 10px !important;">Region</th>
                                    <th style="width: 10%; padding-left: 10px !important;" class="thBeatEmp">Beat Employee</th>
                                    <th style="width: 3%; padding-left: 10px !important;">Unit</th>
                                    <th style="width: 3%; text-align: center; padding-left: 3px !important;">Active</th>
                                    <th style="width: 7%; padding-left: 5px !important;">Updated By</th>
                                    <th style="width: 7%; text-align: center;">Update Date / Time</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div id="divUserUnitMapReport" class="divUserUnitMapReport" style="max-height: 50vh; overflow-y: auto;">
                        <table id="gvUserUnitMapHistory" class="gvUserUnitMapHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="text-align: center; width: 2%;">Sr</th>
                                    <th style="width: 10%; padding-left: 10px !important;" class="thUser">Back Office / User</th>
                                    <th style="width: 15%; padding-left: 10px !important;" class="thDist">Distributor</th>
                                    <th style="width: 15%; padding-left: 10px !important;" class="thss">Super Stokiest</th>
                                    <th style="width: 7%; padding-left: 10px !important;">Region</th>
                                    <th style="width: 8%; padding-left: 10px !important;" class="thBeatEmp">Beat Employee</th>
                                    <th style="width: 2%; padding-left: 10px !important; text-align: right;">Unit</th>
                                    <th style="width: 2%;">Active</th>
                                    <th style="width: 3%;">Deleted</th>
                                    <th style="width: 6%; padding-left: 10px !important;">Update By</th>
                                    <th style="width: 6%;">Update Date/Time</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
        </div>
     
</asp:Content>

