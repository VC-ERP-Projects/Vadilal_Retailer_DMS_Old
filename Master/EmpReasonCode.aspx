<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="EmpReasonCode.aspx.cs" Inherits="Master_EmpReasonCode" %>

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
        const JsonReasonCode = [];
        $(document).ready(function () {
            $('#CountRowEmpReason').val(0);
            // $('#tblDivReason').DataTable().clear().destroy();
            ClearControls();

            //   $("#tblDivReason").tableHeadFixer('90vh');
            //  $("#gvEmpReasonHistory").tableHeadFixer('60vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
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
            });
            // Employee
            $(document).on('keyup', '.AutoEmpName', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoEmpName", '');
                $('#AutoEmpName' + col1).autocomplete({
                    source: function (request, response) {
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strRegionId':'" + 0 + "'}",
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

            $('.AutoEmpName').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoEmpName", '');
                $('#AutoEmpName' + col1).val(ui.item.value);
            });

            $('.AutoEmpName').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoEmpName' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });

            $('.AutoEmpName').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoEmpName", '');
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
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + col1).val().trim(), $('#AutoReason' + col1).val().trim(), col1, 1, $('#AutoEmpFwd' + col1).val().trim(), $('#AutoRegion' + col1).val().trim(), $('#AutoSubEmpName' + col1).val().trim());
                }
            });
            // End Employee


            // Sub Employee
            // Start Search Sub-Employee
            $(document).on('keyup', '.AutoSubEmpName', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoSubEmpName", '');
                $('#AutoSubEmpName' + col1).autocomplete({
                    source: function (request, response) {
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strRegionId':'" + 0 + "'}",
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
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoSubEmpName' + col1),
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
                        $('#AutoSubEmpName' + col1).val(ui.item.value + " ");
                        $('#hdnSubEmpId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });
            //   console.log(indE);

            $('.AutoSubEmpName').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoSubEmpName", '');
                $('#AutoSubEmpName' + col1).val(ui.item.value);
            });


            $('.AutoSubEmpName').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoSubEmpName' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });



            $('.AutoSubEmpName').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoSubEmpName", '');
                if ($('#AutoSubEmpName' + col1).val().trim() != "") {
                    if ($('#AutoSubEmpName' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Sub Employee Name", 3);
                        $('#AutoSubEmpName' + col1).val("");
                        $('#hdnSubEmpId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoSubEmpName' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + col1).val().trim(), $('#AutoReason' + col1).val().trim(), col1, 5, $('#AutoEmpFwd' + col1).val().trim(), $('#AutoRegion' + col1).val().trim(), $('#AutoSubEmpName' + col1).val().trim());
                }
            });

            //End Sub Employee


            // Start Fwd Employee
            
            $(document).on('keyup', '.AutoEmpFwd', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoEmpFwd", '');
                $('#AutoEmpFwd' + col1).autocomplete({
                    source: function (request, response) {
                        var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strRegionId':'" + 0 + "'}",
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
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoEmpFwd' + col1),
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
                        $('#AutoEmpFwd' + col1).val(ui.item.value + " ");
                        $('#hdnFwdEmpId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });
         
            $('.AutoEmpFwd').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoEmpFwd", '');
                $('#AutoEmpFwd' + col1).val(ui.item.value);
            });


            $('.AutoEmpFwd').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoEmpFwd' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });



            $('.AutoEmpFwd').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoEmpFwd", '');
                if ($('#AutoEmpFwd' + col1).val().trim() != "") {
                    if ($('#AutoEmpFwd' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Fwd Employee Name", 3);
                        $('#AutoEmpFwd' + col1).val("");
                        $('#hdnFwdEmpId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpFwd' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + col1).val().trim(), $('#AutoReason' + col1).val().trim(), col1, 3, $('#AutoEmpFwd' + col1).val().trim(), $('#AutoRegion' + col1).val().trim(), $('#AutoSubEmpName' + col1).val().trim());
                }
            });
            // End Fwd Employee

            // Start Region
            $(document).on('keyup', '.AutoRegion', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoRegion", '');
                $('#AutoRegion' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchRegion',
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
                        })
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoRegion' + col1),
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
                        $('#AutoRegion' + col1).val(ui.item.value + " ");
                        $('#hdnRegionId' + col1).val(ui.item.value.split("-")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoRegion').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoRegion", '');
                $('#AutoRegion' + col1).val(ui.item.value);
            });


            $('.AutoRegion').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoRegion' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });



            $('.AutoRegion').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoRegion", '');
                if ($('#AutoRegion' + col1).val().trim() != "") {
                    if ($('#AutoRegion' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Region", 3);
                        $('#AutoRegion' + col1).val("");
                        $('#hdnRegionId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoRegion' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + col1).val().trim(), $('#AutoReason' + col1).val().trim(), col1, 4, $('#AutoEmpFwd' + col1).val().trim(), $('#AutoRegion' + col1).val().trim(), $('#AutoSubEmpName' + col1).val().trim());
                }
            });

            // ENd Region

            // Start Claim Type
            // Start Region
            $(document).on('keyup', '.AutoReason', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoRegion", '');
                $('#AutoReason' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchReason',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "'}",
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
                        })
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoReason' + col1),
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
                        $('#AutoReason' + col1).val(ui.item.value + " ");
                        $('#hdnReasonId' + col1).val(ui.item.value.split("#")[1].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoReason').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoReason", '');
                $('#AutoReason' + col1).val(ui.item.value);
            });


            $('.AutoReason').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoReason' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });



            $('.AutoReason').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoReason", '');
                if ($('#AutoReason' + col1).val().trim() != "") {
                    if ($('#AutoReason' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Claim Type", 3);
                        $('#AutoReason' + col1).val("");
                        $('#hdnReasonId' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoReason' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + col1).val().trim(), $('#AutoReason' + col1).val().trim(), col1, 2, $('#AutoEmpFwd' + col1).val().trim(), $('#AutoRegion' + col1).val().trim(), $('#AutoSubEmpName' + col1).val().trim());
                }
            });

            // ENd Region

            // End Claim Type
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

        function CheckDuplicateData(pEmpCode, pReasonCode, row3, ChkType, pFwdEmpCode, pRegionCode, pSubEmpCode) {

            var ReasonCode = "", EmpEmpCode = "", FwdEmpCode = "", RegionCode = "", pSubEmpId = "";

            console.log(pSubEmpCode);
            console.log(pRegionCode);
            if (pEmpCode != "") {
                EmpEmpCode = pEmpCode.split("#")[2].trim();
            }

            if (pReasonCode != "") {
                ReasonCode = pReasonCode.split("#")[1].trim();
            }
            if (pFwdEmpCode != "") {
                FwdEmpCode = pFwdEmpCode.split("#")[2].trim();
            }
            if (pRegionCode != "") {
                RegionCode = pRegionCode.split("-")[2].trim();
            }
          
            if (pSubEmpCode != "") {
                pSubEmpId = pSubEmpCode.split("#")[2].trim();
            }
            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            $('#tblDivReason  > tbody > tr').each(function (row2, tr) {
                var EmpCode = $("input[name='AutoEmpName']", this).val() != "" ? $("input[name='AutoEmpName']", this).val().split("#")[2].trim() : "";
                var SubEmpCode = $("input[name='AutoSubEmpName']", this).val() != "" ? $("input[name='AutoSubEmpName']", this).val().split("#")[2].trim() : "";
                var Rsoncode = $("input[name='AutoReason']", this).val() != "" ? $("input[name='AutoReason']", this).val().split("#")[1].trim() : "";


                var FwdEmpCodeId = $("input[name='AutoEmpFwd']", this).val() != "" ? $("input[name='AutoEmpFwd']", this).val().split("#")[2].trim() : "";
                var RegionCodeId = $("input[name='AutoRegion']", this).val() != "" ? $("input[name='AutoRegion']", this).val().split("-")[2].trim() : "";

                var LineNum = $("input[name='hdnLineNum']", this).val();
                var RgnId = $("input[name='hdnReasonId']", this).val();
                var EmpId = $("input[name='hdnEmpId']", this).val();
                var SubEmpId = $("input[name='hdnSubEmpId']", this).val();
                var RegionId = $("input[name='hdnRegionId']", this).val();
                var FwdEmpId = $("input[name='hdnFwdEmpId']", this).val();
                if (ChkType == 1) {
                    if (EmpCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && ReasonCode == RgnId && FwdEmpCode == FwdEmpId && RegionCode == RegionId && pSubEmpId == SubEmpId) {
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
                    if (Rsoncode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && ReasonCode == RgnId && FwdEmpCode == FwdEmpId && RegionCode == RegionId && pSubEmpId == SubEmpId) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoReason' + row3).val('');
                                $('#hdnReasonId' + row3).val(0);
                                errormsg = 'Claim Type is already set for = ' + pReasonCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 3) {
                    if (FwdEmpCodeId != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && ReasonCode == RgnId && FwdEmpCode == FwdEmpId && RegionCode == RegionId && pSubEmpId == SubEmpId) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoEmpFwd' + row3).val('');
                                $('#hdnFwdEmpId' + row3).val(0);
                                errormsg = 'Fwd Employee is already set for = ' + pReasonCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 4) {
                    if (RegionCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && ReasonCode == RgnId && FwdEmpCode == FwdEmpId && RegionCode == RegionId && pSubEmpId == SubEmpId) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoRegion' + row3).val('');
                                $('#hdnRegionId' + row3).val(0);
                                errormsg = 'Region is already set for = ' + pReasonCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 5) {
                    if (SubEmpCode != "") {
                        if (parseInt(row3) != parseInt(LineNum)) {
                            if (EmpEmpCode == EmpId && ReasonCode == RgnId && FwdEmpCode == FwdEmpId && RegionCode == RegionId && pSubEmpId == SubEmpId) {
                                cnt = 1;
                                errRow = row3;
                                $('#AutoSubEmpName' + row3).val('');
                                $('#hdnSubEmpId' + row3).val(0);
                                errormsg = 'Sub-Employee is already set for = ' + pSubEmpCode + ' at row : ' + rowCnt_Claim;
                                console.log(errormsg);
                                return false;
                            }
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
                    $('#AutoDistName' + row3).val('');
                }
                ClearClaimRow(row3);
                ModelMsg(errormsg, 3);
                return false;
            }

            var indE = $('#CountRowEmpReason').val();
            if (indE == row3) {
                AddMoreRow();
            }
        }

        function ClearClaimRow(row) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblDivReason > tbody > tr').each(function (row1, tr) {
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
                $('#tblDivReason > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var hdnEmpReasonId = $("input[name='hdnEmpReasonId']", this).val();
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        var SubEmpName = $("input[name='AutoSubEmpName']", this).val();
                        var ReasonCode = $("input[name='AutoReason']", this).val();
                        var FwdEmpName = $("input[name='AutoEmpFwd']", this).val();
                        var Region = $("input[name='AutoRegion']", this).val();
                        if (EmpName == "" && ReasonCode == "" && FwdEmpName == "" && Region == "" && SubEmpName == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblDivReason > tbody > tr').each(function (row, tr) {
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
            $('#tblDivReason  > tbody > tr').each(function (row2, tr) {
                $(this).remove();
            });
            var IsValid = true;
            $.ajax({
                url: 'EmpReasonCode.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ ddlOptionId: $('.ddlOption').val()}),
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
                        var items = JSON.parse(result.d)
                        if (items.length > 0) {
                            $('#tblDivReason  > tbody > tr').each(function (row2, tr) {
                                $(this).remove();
                            });
                            var trHTML = '';
                            var row4 = 1;
                            $('#CountRowEmpReason').val(0);
                            var indE = $('#CountRowEmpReason').val();
                            $('#CountRowEmpReason').val(indE);
                            var length = 0;
                            var itm = this;
                            for (var i = 0; i < items.length; i++) {
                                row4 = $('#CountRowEmpReason').val();
                                //$('#chkEditEmp' + row4).click();
                                //  $('#chkEditEmp' + row4).prop("checked", false);
                                $('table#divEmpReason tr#NoROW').remove();  // Remove NO ROW
                                /// Add Dynamic Row to the existing Table
                                var indE = $('#CountRowEmpReason').val();
                                indE = parseInt(indE) + 1;
                                $('#CountRowEmpReason').val(indE);
                                var strEmp = "";
                                strEmp = "<tr id='trEmpR" + indE + "'>"
                                    + "<td class='txtSrNo' id='txtSrNo" + indE + "'>" + indE + "</td>"
                                    + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit' checked='false'/>"
                                    + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"

                                    + "<td class='dtbodyCenter'><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indE + ");' /></td>"
                                    + "<td><input type='text' id='AutoEmpName" + indE + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search AutoEmpName' value='" + items[i].EmpName + "' disabled='false' /></td>"
                                    + "<td><input type='text' id='AutoSubEmpName" + indE + "' name='AutoSubEmpName' onchange='ChangeData(this);' class='form-control search AutoSubEmpName' value='" + items[i].SubEmpName + "' disabled='false' /></td>"
                                    + "<td><input type='text' id='AutoRegion" + indE + "' name='AutoRegion' onchange='ChangeData(this);' class='form-control search AutoRegion' value='" + items[i].Region + "' disabled='false' /></td>"
                                    + "<td class='tdClaimType'><input type='text' id='AutoReason" + indE + "' name='AutoReason' onchange='ChangeData(this);' class='form-control search AutoReason' value='" + items[i].Reason + "' disabled='false' /></td>"
                                    + "<td><input type='text' id='AutoEmpFwd" + indE + "' name='AutoEmpFwd' onchange='ChangeData(this);' class='form-control search AutoEmpFwd' value='" + items[i].FwdEmpName + "' disabled='false' /></td>"

                                    + "<td><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox' disabled='false' /></td>"
                                    //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'>" + items[i].CreatedBy + "</td>"
                                    //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'>" + items[i].CreatedDate + "</td>"
                                    + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy CustName'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'>" + items[i].UpdatedDate + "</td>"
                                    + "<input type='hidden' class='hdnEmpReasonId' id='hdnEmpReasonId" + indE + "' name='hdnEmpReasonId' value='" + items[i].OERMId + "'/></td>"
                                    + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + indE + "' name='hdnEmpId' value='" + items[i].EmpId + "'/></td>"
                                    + "<input type='hidden' class='hdnSubEmpId' id='hdnSubEmpId" + indE + "' name='hdnSubEmpId' value='" + items[i].SubEmpId + "'/></td>"
                                    + "<input type='hidden' class='hdnRegionId' id='hdnRegionId" + indE + "' name='hdnRegionId' value='" + items[i].RegionId + "'/>"
                                    + "<input type='hidden' class='hdnFwdEmpId' id='hdnFwdEmpId" + indE + "' name='hdnFwdEmpId' value='" + items[i].FwdToEmpId + "'/>"
                                    + "<input type='hidden' class='hdnReasonId' id='hdnReasonId" + indE + "' name='hdnReasonId' value='" + items[i].ReasonId + "' /></td>"
                                    + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                                    + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";
                                $('#tblDivReason > tbody').append(strEmp);
                                $('#trEmpR' + indE).find('#chkIsActive' + indE).prop("checked", items[i].Active);

                                $('.chkEdit').hide();
                                //  $('.chkEdit').prop("checked", true);
                                $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

                                var table = document.getElementById("tblDivReason");


                            }

                            
                        }
                        else {
                            $('#tblDivReason  > tbody > tr').each(function (row2, tr) {
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

            $('.divEmpReason').attr('style', 'display:none;');
            $('.divEmpReasonReport').attr('style', 'display:none;');

            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblDivReason tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvEmpReasonHistory')) {
                $('.gvEmpReasonHistory').DataTable().destroy();
            }

            $('.gvEmpReasonHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divEmpReasonReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divEmpReason').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowEmpReason').val(0);
                $('#tblDivReason').DataTable().clear().destroy();
                FillData();
                setTimeout(function () {
                    var aryJSONColTable = [];
                    aryJSONColTable.push({ "width": "1px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "1px", "sClass": "dtbodyCenter", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "1px", "sClass": "dtbodyCenter", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "120px", "sClass": "dtbodyLeft", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "120px", "sClass": "dtbodyLeft", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyLeft", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyLeft", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyLeft", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "5px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "65px", "sClass": "dtbodyLeft", "aTargets": 9 });//"sClass": "dtbodyLeft",
                    aryJSONColTable.push({ "width": "45px", "aTargets": 10 });
                    $('#tblDivReason').DataTable({
                        bFilter: false,
                        scrollCollapse: true,
                        "sExtends": "collection",
                        scrollX: false,
                        scrollY: '67vh',
                        responsive: true,
                        "bPaginate": false,
                        "bInfo": true,
                        "autoWidth": false,
                        destroy: true,
                        scroller: false,
                        "bProcessing": true,
                        "bDeferRender": true,
                        "aoColumnDefs": aryJSONColTable,
                    });
                }, 200)
            }
        }
        function RemoveClaimLockingRow(row) {

            var DiscountExcId = $('table#tblDivReason tr#trEmpR' + row).find(".hdnEmpReasonId").val();
            $('table#tblDivReason tr#trEmpR' + row).find(".IsChange").val("1");
            $('table#tblDivReason tr#trEmpR' + row).remove();
            $('table#tblDivReason tr#trEmpR' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblDivReason tr#trEmpR' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }
        function AddMoreRow() {
            $('table#tblDivReason tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var indE = $('#CountRowEmpReason').val();

            indE = parseInt(indE) + 1;
            $('#CountRowEmpReason').val(indE);

            var strEmp = "";
            strEmp = "<tr id='trEmpR" + indE + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + indE + "'>" + indE + "</td>"
                + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td class='dtbodyCenter'><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indE + ");' /></td>"
                + "<td><input type='text' id='AutoEmpName" + indE + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search AutoEmpName' /></td>"
                + "<td><input type='text' id='AutoSubEmpName" + indE + "' name='AutoSubEmpName' onchange='ChangeData(this);' class='form-control search AutoSubEmpName' /></td>"
                + "<td><input type='text' id='AutoRegion" + indE + "' name='AutoRegion' onchange='ChangeData(this);' class='form-control search AutoRegion' /></td>"
                + "<td class='tdClaimType'><input type='text' id='AutoReason" + indE + "' name='AutoReason' onchange='ChangeData(this);' class='form-control search AutoReason' /></td>"
                + "<td><input type='text' id='AutoEmpFwd" + indE + "' name='AutoEmpFwd' onchange='ChangeData(this);' class='form-control search AutoEmpFwd' /></td>"
                + "<td><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"
                //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'></td>"
                //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'></td>"

                + "<input type='hidden' class='hdnEmpReasonId' id='hdnEmpReasonId" + indE + "' name='hdnEmpReasonId'/></td>"
                + "<input type='hidden' class='hdnRegionId' id='hdnRegionId" + indE + "' name='hdnRegionId'  /></td>"
                + "<input type='hidden' class='hdnReasonId' id='hdnReasonId" + indE + "' name='hdnReasonId'  /></td>"
                + "<input type='hidden' class='hdnFwdEmpId' id='hdnFwdEmpId" + indE + "' name='hdnFwdEmpId'  /></td>"
                + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + indE + "' name='hdnEmpId'  /></td>"
                + "<input type='hidden' class='hdnSubEmpId' id='hdnSubEmpId" + indE + "' name='hdnSubEmpId'  />"
                + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";

            $('#tblDivReason > tbody').append(strEmp);
            if ($('.ddlOption').val() != 1) {
                    $('.thClaimType').hide();
                    $('.tdClaimType').hide();
            }
            else {
                $('.thClaimType').show();
                $('.tdClaimType').show();
            }
            $('.chkEdit').hide();
            //  $('.chkEdit').prop("checked", true);
            var table = document.getElementById("tblDivReason");

            //Start Employee  Textbox


            $('#AutoEmpName' + indE).keyup(function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();

                $('#AutoEmpName' + indE).autocomplete({
                    source: function (request, response) {
                        var RegionId = $("#AutoRegion" + indE).val() != "" && $("#AutoRegion" + indE).val() != undefined ? $("#AutoRegion" + indE).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strRegionId':'" + 0 + "'}",
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
            });
            $('#AutoEmpName' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoEmpName' + indE).val(ui.item.value);
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
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + indE).val().trim(), $('#AutoReason' + indE).val().trim(), indE, 1, $('#AutoEmpFwd' + indE).val().trim(), $('#AutoRegion' + indE).val().trim(), $('#AutoSubEmpName' + indE).val().trim());
                }
            });

            //End Employee Textbox


            //Start Sub-Employee  Textbox


            $('#AutoSubEmpName' + indE).keyup(function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();

                $('#AutoSubEmpName' + indE).autocomplete({
                    source: function (request, response) {
                        var RegionId = $("#AutoRegion" + indE).val() != "" && $("#AutoRegion" + indE).val() != undefined ? $("#AutoRegion" + indE).val().split("-")[2].trim() : "0";
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strRegionId':'" + 0 + "'}",
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
                    position: { collision: "flip" },
                    select: function (event, ui) {
                        $('#hdnSubEmpId' + indE).val(ui.item.value.split('#')[2].trim());
                        $('#AutoSubEmpName' + indE).val(ui.item.value + " ");
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });
            $('#AutoSubEmpName' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoSubEmpName' + indE).val(ui.item.value);
            });

            $('#AutoSubEmpName' + indE).on('change keyup', function () {
                if ($('#AutoSubEmpName' + indE).val() == "") {
                    ClearClaimRow(indE);
                }
            });

            $('#AutoSubEmpName' + indE).on('blur', function (e, ui) {
                if ($('#AutoSubEmpName' + indE).val().trim() != "") {
                    if ($('#AutoSubEmpName' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Sub-Employee Name", 3);
                        $('#AutoSubEmpName' + indE).val("");
                        $('#AutoSubEmpName' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoSubEmpName' + indE).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + indE).val().trim(), $('#AutoReason' + indE).val().trim(), indE, 5, $('#AutoEmpFwd' + indE).val().trim(), $('#AutoRegion' + indE).val().trim(), $('#AutoSubEmpName' + indE).val().trim());
                }
            });

            //End Employee Textbox
            // Fwd Emp
            $('#AutoEmpFwd' + indE).keyup(function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoEmpFwd' + indE).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strRegionId':'" + 0 + "'}",
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
                    position: { collision: "flip" },
                    select: function (event, ui) {
                        $('#hdnFwdEmpId' + indE).val(ui.item.value.split('#')[2].trim());
                        $('#AutoEmpFwd' + indE).val(ui.item.value + " ");
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });
            $('#AutoEmpFwd' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoEmpFwd' + indE).val(ui.item.value);
            });

            $('#AutoEmpFwd' + indE).on('change keyup', function () {
                if ($('#AutoEmpFwd' + indE).val() == "") {
                    ClearClaimRow(indE);
                }
            });

            $('#AutoEmpFwd' + indE).on('blur', function (e, ui) {
                if ($('#AutoEmpFwd' + indE).val().trim() != "") {
                    if ($('#AutoEmpFwd' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Fwd Employee Name", 3);
                        $('#AutoEmpFwd' + indE).val("");
                        $('#hdnFwdEmpId' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpFwd' + indE).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + indE).val().trim(), $('#AutoReason' + indE).val().trim(), indE, 3, $('#AutoEmpFwd' + indE).val().trim(), $('#AutoRegion' + indE).val().trim(), $('#AutoSubEmpName' + indE).val().trim());
                }
            });


            //

            // Region


            $('#AutoRegion' + indE).keyup(function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $('#AutoRegion' + indE).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'EmpReasonCode.aspx/SearchRegion',
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
                        $('#hdnRegionId' + indE).val(ui.item.value.split('-')[2].trim());
                        $('#AutoRegion' + indE).val(ui.item.value + " ");
                    },
                    change: function (event, ui) {
                        if (!ui.item) {
                        }
                    },
                    minLength: 1
                });
            });
            $('#AutoRegion' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoRegion' + indE).val(ui.item.value);
            });

            $('#AutoRegion' + indE).on('change keyup', function () {
                if ($('#AutoRegion' + indE).val() == "") {
                    ClearClaimRow(indE);
                }
            });

            $('#AutoRegion' + indE).on('blur', function (e, ui) {
                if ($('#AutoRegion' + indE).val().trim() != "") {
                    if ($('#AutoRegion' + indE).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Region", 3);
                        $('#AutoRegion' + indE).val("");
                        $('#hdnRegionId' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoRegion' + indE).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + indE).val().trim(), $('#AutoReason' + indE).val().trim(), indE, 4, $('#AutoEmpFwd' + indE).val().trim(), $('#AutoRegion' + indE).val().trim(), $('#AutoSubEmpName' + indE).val().trim());
                }
            });

            // End Region

            //Start Reasoncode Textbox           
            //$('#AutoReason' + indE).keyup(function () {
            //    var textValue = $(this).val();
            //    var currentRow = $(this).closest("tr");
            //    var col1 = currentRow.find("td:eq(0)").text();
            //    $('#AutoReason' + col1).autocomplete({
            //        source: function (request, response) {
            //            $.ajax({
            //                type: "POST",
            //                url: 'EmpReasonCode.aspx/SearchReason',
            //                dataType: "json",
            //                data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
            //                contentType: "application/json; charset=utf-8",
            //                success: function (data) {
            //                    response($.map(data.d, function (item) {
            //                        return {
            //                            label: item.Text,
            //                            value: item.Text,
            //                            id: item.Value
            //                        };
            //                    }))
            //                },
            //                error: function (XMLHttpRequest, textStatus, errorThrown) {
            //                }
            //            });
            //        },
            //        select: function (event, ui) {
            //            var currentRow = $(this).closest("tr");
            //            var col1 = currentRow.find("td:eq(0)").text();
            //            $('#AutoReason' + col1).val(ui.item.value + " ");
            //            $('#hdnReasonId' + col1).val(ui.item.value.split("#")[2].trim());
            //        },
            //        change: function (event, ui) {
            //            if (!ui.item) {

            //            }
            //        },
            //        minLength: 1
            //    });
            //});

            $('#AutoReason' + indE).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'EmpReasonCode.aspx/SearchReason',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "'}",
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
                position: { collision: "flip" },
                select: function (event, ui) {
                    $('#hdnReasonId' + indE).val(ui.item.value.split('#')[1].trim());
                    $('#AutoReason' + indE).val(ui.item.value + " ");
                    //   $('#hdnReasonId' + indE).val(ui.item.value.split("#")[2].trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                    }
                },
                minLength: 1
            });

            $('#AutoReason' + indE).on('autocompleteselect', function (e, ui) {

                $('#AutoReason' + indE).val(ui.item.value);
            });

            $('#AutoReason' + indE).on('change keyup', function () {
                if ($('#AutoReason' + indE).val() == "") {

                    ClearClaimRow(indE);
                    // $('#hdnDistId' + indE).val(0);

                }
            });

            $('#AutoReason' + indE).on('blur', function (e, ui) {
                if ($('#AutoReason' + indE).val().trim() != "") {

                    if ($('#AutoReason' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Reason Code", 3);
                        $('#AutoReason' + indE).val("");
                        $('#hdnReasonId' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoReason' + indE).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDivReason > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoEmpName' + indE).val().trim(), $('#AutoReason' + indE).val().trim(), indE, 2, $('#AutoEmpFwd' + indE).val().trim(), $('#AutoRegion' + indE).val().trim(), $('#AutoSubEmpName' + indE).val().trim());
                }
            });
            //End Reason textbox
        }
        function Cancel() {
            window.location = "../Master/EmpReasonCode.aspx";
        }
        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowEmpReason').val();
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

            $('#tblDivReason  > tbody > tr').each(function (row, tr) {
                var EmpName = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();
                var SubEmpName = $("input[name='AutoSubEmpName']", this).val().split('#').pop().trim();
                var Reason = $("input[name='AutoReason']", this).val().split('#').pop().trim();
                var IsDeleted = $('#hdnIsRowDeleted').val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                if ($('.ddlOption').val() != 1) {
                    Reason = 'No Validation';
                }
                if ((EmpName != "" && Reason != "") && (IsChange == "1" || IsDeleted == 1)) {
                    totalItemcnt = 1;
                    var EmpReasonId = $("input[name='hdnEmpReasonId']", this).val().trim();
                    var hdnEmpId = $("input[name='hdnEmpId']", this).val().trim();
                    var hdnSubEmpId = $("input[name='hdnSubEmpId']", this).val().trim();
                    var hdnReasonId = $("input[name='hdnReasonId']", this).val().trim();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var IPAddress = $("#hdnIPAdd").val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();

                    var hdnRegionId = $("input[name='hdnRegionId']", this).val().trim();
                    var hdnFwdEmpId = $("input[name='hdnFwdEmpId']", this).val().trim();
                    var obj = {
                        OERMId: EmpReasonId,
                        EmpId: hdnEmpId,
                        SubEmpId: hdnSubEmpId,
                        ReasonId: hdnReasonId,
                        Active: IsActive,
                        IPAddress: IPAddress,
                        IsChange: IsChange,
                        RegionId: hdnRegionId,
                        FwdEmpId: hdnFwdEmpId
                    };
                    TableData_Claim.push(obj);
                    rowCnt_Claim++;
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
            var ClaimProcessData = JSON.stringify(TableData_Claim);
            //console.log(ClaimProcessData);
            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'EmpReasonCode.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputScanningType: ClaimProcessData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val(), OptionId: $('.ddlOption').val() }),
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


        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();

                $('.gvEmpReasonHistory tbody').empty();
                $.ajax({
                    url: 'EmpReasonCode.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','ddlOptionId':'" + $('.ddlOption').val()+"'}",
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
                                    + "<td>" + ReportData[i].EmpName + "</td>"
                                    + "<td>" + ReportData[i].SubEmpName + "</td>"
                                    + "<td>" + ReportData[i].Region + "</td>"
                                    + "<td class='CustName tdReportClaimType'>" + ReportData[i].Reason + "</td>"
                                    + "<td>" + ReportData[i].FwdEmpName + "</td>"
                                    + "<td>" + ReportData[i].IsActive + "</td>"
                                    + "<td>" + ReportData[i].IsDeleted + "</td>"
                                    //+ "<td>" + ReportData[i].CreatedBy + "</td>"
                                    //+ "<td>" + ReportData[i].CreatedDate + "</td>"
                                    + "<td class='CustName'>" + ReportData[i].UpdatedBy + "</td>"
                                    + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"
                                //+ "<td>" + ReportData[i].Employee + "</td>
                                k = k + 1;
                                $('.gvEmpReasonHistory > tbody').append(str);
                            }
                            if ($('.ddlOption').val() != 1) {
                                    $('.thReportClaimType').hide();
                                    $('.tdReportClaimType').hide();
                            }
                            else {
                                $('.thReportClaimType').show();
                                $('.tdReportClaimType').show();
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvEmpReasonHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyLeft", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyLeft", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyLeft", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyLeft", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 9 });

                    $('.gvEmpReasonHistory').DataTable({
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
                        columnDefs: [ {
                            targets: -1,
                            visible: false
                        }],
                        buttons: [{
                            extend: 'copy', footer: true,
                            exportOptions: {
                                columns: ':visible',
                            }
                        },
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
                            },
                            customize: function (xlsx) {

                                sheet = ExportXLS(xlsx, 5);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r3 = Addrow(2, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                var r4 = Addrow(3, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r5 = Addrow(4, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                var r6 = Addrow(5, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r6 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                order: 'applied',
                                
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
                                    doc.content[0].table.body[i][6].alignment = 'center';
                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'left';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'left';
                                doc.content[0].table.body[0][6].alignment = 'center';
                                doc.content[0].table.body[0][7].alignment = 'center';
                                doc.content[0].table.body[0][8].alignment = 'left';
                                if ($(".ddlOption").val() == 1) {
                                    doc.content[0].table.body[0][9].alignment = 'center';
                                }
                            }
                        }]
                    });
                }
            }
        }

        function ShowDataOnChange() {
            var option = $(".ddlOption").val();

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();
            }
            else {
                ClearControls();
            }
            //if (option == 1) {
                
            //    $('.thClaimType').show();
            //    $('.tdClaimType').show();
            //    $('.thReportClaimType').show();
            //    $('.tdReportClaimType').show();
            //}
            //else if (option != 1) {
            //    $('.thClaimType').hide();
            //    $('.tdClaimType').hide();
            //    $('.thReportClaimType').hide();
            //    $('.tdReportClaimType').hide();
            //}
        }
    </script>
    <style>
        table.dataTable thead .sorting,
        table.dataTable thead .sorting_asc,
        table.dataTable thead .sorting_desc {
            background: none;
        }

        .body {
            overflow: hidden !important;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 2px 5px !important;
        }

        table.tblDiscountExc.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .ui-widget {
            font-size: 12px;
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

        input.txtCompContri, input.txtDistContri, .tdUniqueNo {
            text-align: right;
        }

        td.txtSrNo, .tdCreatedDate, .tdUpdateDate {
            text-align: center;
        }

        .ui-autocomplete {
            position: absolute;
        }

        table#tblDiscountExc.dataTable tbody th {
            padding-left: 6px !important;
        }

        table#tblEmpDiscount.dataTable tbody th {
            padding-left: 6px !important;
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

        #tblDivReason {
            margin-top: 0px !important;
        }


        /*div:not(.dataTables_scrollFoot):not(.dataTables_scrollBody)::-webkit-scrollbar { display: none; }*/

        .dataTables_scrollBody {
            overflow: auto !important;
        }

        dataTables_scroll .dataTables_scrollBody {
            overflow-y: hidden !important;
            overflow-x: hidden !important;
            max-height: none !important;
        }

        .dataTables_wrapper .dataTables_scroll {
            clear: both;
            width: 100%;
            /*height: 73vh;*/
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
        /*.dataTables_scrollBody {
            width: 100%;
        }*/
        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1430px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
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

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />
    <div class="panel panel-default">
        <div class="panel-body" style="height: 560px !important;">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <select name="ctl00$body$ddlOption" id="body_ddlOption" tabindex="1" class="ddlOption form-control" onchange="ShowDataOnChange();">
                            <option selected="selected" value="1">Claim Process</option>
                            <option value="2">Asset Request Process</option>
                            <option value="3">DAL Request Process</option>
                            <option value="4">GSB Request Process</option>
                        </select>
                    </div>
                </div>
            <div class="col-lg-2">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="3" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="divViewDetail" style="display: none;">
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
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" tabindex="5" onclick="btnSubmit_Click()" class="btnSubmit btn btn-default" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" tabindex="6" class="btnSearch btn btn-default" onclick="GetReport();" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" tabindex="7" onclick="Cancel()" class="btn btn-default" />
                    </div>
                </div>
            </div>
            <div class="row _masterForm">
                <div class="col-lg-12">
                    <input type="hidden" id="CountRowEmpReason" />
                    <div id="divEmpReason" class="divEmpReason" runat="server" style="max-height: 50vh; position: absolute;">
                        <table id="tblDivReason" class="table table-bordered nowrap" border="1" tabindex="8" style="border-collapse: collapse; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="width: 3% !important; text-align: center;">Sr</th>
                                    <th style="text-align: center;">Edit</th>
                                    <th style="text-align: center;">Delete</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Employee</th>
                                       <th style="width: 20%; padding-left: 10px !important;">Sub-Employee</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Region</th>
                                    <th style="width: 20%; padding-left: 10px !important;" class="thClaimType">Claim Type</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Fwd To</th>
                                    <th style="width: 3% !important; text-align: center; padding-left: 3px !important;">Active</th>
                                    <th style="width: 7%; padding-left: 5px !important;">Updated By</th>
                                    <th style="width: 7%; text-align: center;">Update Date / Time</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div id="divEmpReasonReport" class="divEmpReasonReport" style="max-height: 50vh; overflow-y: auto;">
                        <table id="gvEmpReasonHistory" class="gvEmpReasonHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="text-align: center; width: 2%;">Sr</th>
                                    <th style="width: 10%">Employee</th>
                                     <th style="width: 10%">Sub-Employee</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Region</th>
                                    <th style="width: 10%;padding-left: 10px !important;" class="thReportClaimType">Claim Type</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Fwd To</th>
                                    <th style="width: 3%;">Active</th>
                                    <th style="width: 3%;">Deleted</th>
                                    <th style="width: 5%;padding-left: 10px !important;"">Update By</th>
                                    <th style="width: 5%;">Update Date/Time</th>
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
</asp:Content>

