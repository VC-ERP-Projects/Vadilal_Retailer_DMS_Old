<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ClaimLockingMaster.aspx.cs" Inherits="Master_ClaimLockingMaster" %>

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

        var Version = '<% = Version%>';
      //  var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var IpAddress;

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

            ShowDistOrSS();
            ClearControls();
            $("#tblClaim").tableHeadFixer('80vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            //FillData();
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox,.days').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox,.days').prop('disabled', true);
                    $(this).val('Edit');
                }
            });

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
        function ShowDistOrSSOnChange() {

            var option = $(".ddlOption").val();
            if (option == 1) {
                $('#tblClaim').find('th:nth-child(7)').hide();
                $('.tdSS').hide();
                ClearClaimRow();
                $('#tblClaim').find('th:nth-child(6)').show();
                $('.tdDist').show();
                $('#tblClaim').find('th:nth-child(4)').show();
                $('.tdRegion').show();

            }
            else if (option == 2) {
                $('#tblClaim').find('th:nth-child(6)').hide();
                $('.tdDist').hide();
                ClearClaimRow();
                $('#tblClaim').find('th:nth-child(7)').show();
                $('.tdSS').show();
                $('#tblClaim').find('th:nth-child(4)').show();
                $('.tdRegion').show();

            }
            else if (option == 3) {
                $('#tblClaim').find('th:nth-child(6)').hide();
                $('#tblClaim').find('th:nth-child(7)').hide();
                $('.tdSS').hide();
                $('.tdDist').hide();
                $('#tblClaim').find('th:nth-child(4)').hide();
                $('.tdRegion').hide();
                ClearClaimRow();
            }
            else {
                $('#tblClaim').find('th:nth-child(7)').hide();
                $('.tdSS').hide();
                //ClearClaimRow();
            }
            ClearControls();
            $('#hdnDeleteIDs').val('');
            $('#hdnIsRowDeleted').val("0");

        }
        function ShowDistOrSS() {

            var option = $(".ddlOption").val();
            if (option == 1) {
                $('#tblClaim').find('th:nth-child(7)').hide();
                $('.tdSS').hide();
                ClearClaimRow();
                $('#tblClaim').find('th:nth-child(6)').show();
                $('.tdDist').show();
                $('#tblClaim').find('th:nth-child(4)').show();
                $('.tdRegion').show();

            }
            else if (option == 2) {
                $('#tblClaim').find('th:nth-child(6)').hide();
                $('.tdDist').hide();
                ClearClaimRow();
                $('#tblClaim').find('th:nth-child(7)').show();
                $('.tdSS').show();
                $('#tblClaim').find('th:nth-child(4)').show();
                $('.tdRegion').show();

            }
            else if (option == 3) {
                $('#tblClaim').find('th:nth-child(6)').hide();
                $('#tblClaim').find('th:nth-child(7)').hide();
                $('.tdSS').hide();
                $('.tdDist').hide();
                $('#tblClaim').find('th:nth-child(4)').hide();
                $('.tdRegion').hide();
                ClearClaimRow();
            }
            else {
                $('#tblClaim').find('th:nth-child(7)').hide();
                $('.tdSS').hide();
                //ClearClaimRow();
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
        function AddMoreRow() {
            $('table#tblClaim tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowClaim').val();

            ind = parseInt(ind) + 1;
            $('#CountRowClaim').val(ind);

            var str = "";
            str = "<tr id='trClaim" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + ind + ");' /></td>"
                + "<td class='tdRegion'><input type='text' id='AutoRegion" + ind + "' name='AutoRegion' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td><input type='text' id='AutoEmpName" + ind + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdDist'><input type='text' id='AutoDistName" + ind + "' name='AutoDistName' onchange='ChangeData(this);' class='form-control search Dist' /></td>"
                + "<td class='tdSS'><input type='text' id='AutoSSName" + ind + "' name='AutoSSName' onchange='ChangeData(this);' class='form-control search SS' /></td>"
                + "<td><input type='text' id='days" + ind + "' name='days' onchange='ChangeData(this);' maxlength='4' onkeypress='return isNumber(event)' class='form-control days'/></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td id='tdCreatedBy" + ind + "' class='tdCreatedBy'></td>"
                + "<td id='tdCreatedDate" + ind + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDate" + ind + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnClaimLockingId' id='hdnClaimLockingId" + ind + "' name='hdnClaimLockingId'/></td>"
                + "<input type='hidden' class='hdnRegionId' id='hdnRegionId" + ind + "' name='hdnRegionId'  /></td>"
                + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + ind + "' name='hdnEmpId'  /></td>"
                + "<input type='hidden' class='hdnDistId' id='hdnDistId" + ind + "' name='hdnDistId'  /></td>"
                + "<input type='hidden' class='hdnSSId' id='hdnSSId" + ind + "' name='hdnSSId'  /></td>"
                + "<input type='hidden' class='hdnDaysId' id='hdnDaysId" + ind + "' name='hdnDaysId'  /></td>"
                + "<input type='hidden' class='IsChange' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";

            $('#tblClaim > tbody').append(str);
            ShowDistOrSS();
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
            var table = document.getElementById("tblClaim");
            //Start Region Textbox
            $('#AutoRegion' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: 'ClaimLockingMaster.aspx/SearchRegion',
                        type: "POST",
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            console.log(data);
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
                    //$('#hdnRegionId' + ind).val(0);
                    //$('#AutoRegion' + ind).val("");
                    $('#hdnRegionId' + ind).val(ui.item.id);
                    // $('#hdnEmpID' + ind).val(ui.item.value.split('#')[2].trim());
                    $('#AutoRegion' + ind).val(ui.item.value + " ");
                    $('#AutoEmpName' + ind).val("");
                    $('#hdnEmpId' + ind).val(0);
                    $('#AutoDistName' + ind).val("");
                    $('#hdnDistId' + ind).val(0);
                    $('#AutoSSName' + ind).val("");
                    $('#hdnSSId' + ind).val("");

                    
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        //$('#hdnRegionId' + ind).val(0);
                        //$('#AutoRegion' + ind).val("");
                        //$('#AutoEmpName' + ind).val("");
                        //$('#hdnEmpId' + ind).val(0);
                        //$('#AutoDistName' + ind).val("");
                        //$('#hdnDistId' + ind).val(0);
                        //$('#AutoSSName' + ind).val("");
                        //$('#hdnSSId' + ind).val("");
                        //$('#chkIsActive' + ind).prop('checked', false);
                        //$('#chkIsActive' + ind).attr("disabled", false);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoRegion' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                        inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoRegion' + ind).position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                    $results.css("top", newTop + "px");
                },

                minLength: 1
            });
            $('#AutoRegion' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoRegion' + ind).val(ui.item.value);
            });

            $('#AutoRegion' + ind).on('change keyup', function () {
                if ($('#AutoRegion' + ind).val() == "") {
                    ClearClaimRow(ind);
                }
            });

            $('#AutoRegion' + ind).on('blur', function (e, ui) {
               
                if ($('#AutoRegion' + ind).val().trim() != "") {
                    if ($('#AutoRegion' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Region", 3);
                        $('#AutoRegion' + ind).val("");
                        $('#hdnRegionId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoRegion' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblClaim > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 1);
                }
            });

            //Start Employee  Textbox
            $('#AutoEmpName' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'ClaimLockingMaster.aspx/SearchEmployee',
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
                select: function (event, ui) {
                    $('#hdnEmpId' + ind).val(ui.item.id);
                    // $('#hdnEmpID' + ind).val(ui.item.value.split('#')[2].trim());
                    $('#AutoEmpName' + ind).val(ui.item.value + " ");
                    //$('#AutoCustName' + ind).val("");
                    //$('#hdnCustId' + ind).val(0);
                    $('#tdFromDate' + ind).text('');
                    $('#tdToDate' + ind).text('');
                    //$('#txtCompContri' + ind).val("");
                    //$('#txtDistContri' + ind).val("");
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        //$('#AutoEmpName' + ind).val("");
                        //$('#hdnEmpId' + ind).val(0);
                        ////$('#AutoCustName' + ind).val("");
                        ////$('#hdnCustId' + ind).val(0);
                        ////$('#tdFromDate' + ind).text('');
                        ////$('#tdToDate' + ind).text('');
                        ////$('#txtCompContri' + ind).val("");
                        ////$('#txtDistContri' + ind).val("");
                        //$('#chkIsActive' + ind).prop('checked', false);
                        //$('#chkIsActive' + ind).attr("disabled", false);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoEmpName' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                        inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoEmpName' + ind).position().top : table.offsetHeight,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                    $results.css("top", newTop + "px");
                },

                minLength: 1
            });
            $('#AutoEmpName' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoEmpName' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoEmpName' + ind).on('change keyup', function () {
                if ($('#AutoEmpName' + ind).val() == "") {
                    ClearClaimRow(ind);
                }
            });

            $('#AutoEmpName' + ind).on('blur', function (e, ui) {
                if ($('#AutoEmpName' + ind).val().trim() != "") {
                    if ($('#AutoEmpName' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Employee Name", 3);
                        $('#AutoEmpName' + ind).val("");
                        $('#hdnEmpId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpName' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblClaim > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 2);
                }
            });

            //End Employee Textbox

            //Start Distributor Textbox           
            $('#AutoDistName' + ind).autocomplete({
                source: function (request, response) {
                    var EmpId = $("#AutoEmpName" + ind).val() != "" && $("#AutoEmpName" + ind).val() != undefined ? $("#AutoEmpName" + ind).val().split("-")[2].trim() : "0";
                    var RegionId = $("#AutoRegion" + ind).val() != "" && $("#AutoRegion" + ind).val() != undefined ? $("#AutoRegion" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'ClaimLockingMaster.aspx/SearchDistributor',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "'}",
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

                    $('#AutoDistName' + ind).val(ui.item.value + " ");
                    $('#hdnDistId' + ind).val(ui.item.value.split("-")[2].trim());
                    //$('#hdnCustId' + ind).val(ui.item.value.split("-")[2].trim());
                    // $('#AutoDistName' + ind).val("");
                    //$('#hdnDistId' + ind).val(0);
                    
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        //$('#AutoCustName' + ind).val("");
                        //$('#hdnCustId' + ind).val(0);
                        // $('#AutoDistName' + ind).val("");
                        // $('#hdnDistId' + ind).val(0);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoDistName' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                        inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoDistName' + ind).position().top : table.offsetHeight,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                    $results.css("top", newTop + "px");
                },
                minLength: 1
            });

            $('#AutoDistName' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoDistName' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoDistName' + ind).on('change keyup', function () {
                if ($('#AutoDistName' + ind).val() == "") {
                    ClearClaimRow(ind);
                    // $('#hdnDistId' + ind).val(0);

                }
            });

            $('#AutoDistName' + ind).on('blur', function (e, ui) {
                if ($('#AutoDistName' + ind).val().trim() != "") {
                    if ($('#AutoDistName' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Distributor Name", 3);
                        $('#AutoDistName' + ind).val("");
                        $('#hdnDistId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoDistName' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblClaim > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 3);
                }
            });
            //End Distributor textbox
            //Start SuperStockiest textBox
            $('#AutoSSName' + ind).autocomplete({
                source: function (request, response) {
                    var EmpId = $("#AutoEmpName" + ind).val() != "" && $("#AutoEmpName" + ind).val() != undefined ? $("#AutoEmpName" + ind).val().split("-")[2].trim() : "0";
                    var RegionId = $("#AutoRegion" + ind).val() != "" && $("#AutoRegion" + ind).val() != undefined ? $("#AutoRegion" + ind).val().split("-")[2].trim() : "0";

                    $.ajax({
                        type: "POST",
                        url: 'ClaimLockingMaster.aspx/SearchSuperStockiest',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'"+RegionId+"'}",
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

                    $('#AutoSSName' + ind).val("");
                    $('#hdnSSId' + ind).val(ui.item.value.split("-")[2].trim());
                    $('#tdFromDate' + ind).text('');
                    $('#tdToDate' + ind).text('');
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        // $('#AutoSSName' + ind).val("");
                        //  $('#hdnSSId' + ind).val(0);
                        //$('#AutoDistName' + ind).val("");
                        //$('#hdnDistId' + ind).val(0);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoSSName' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                        inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                    $results.css("top", newTop + "px");
                },
                minLength: 1
            });

            $('#AutoSSName' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoSSName' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoSSName' + ind).on('change keyup', function () {
                if ($('#AutoSSName' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnSSId' + ind).val(0);

                }
            });

            $('#AutoSSName' + ind).on('blur', function (e, ui) {
                if ($('#AutoSSName' + ind).val().trim() != "") {
                    if ($('#AutoSSName' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Super Stockist Name", 3);
                        $('#AutoSSName' + ind).val("");
                        $('#hdnSSId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoSSName' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblClaim > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 4);
                }
            });
            //End SuperStockiest textbox
        }

        function CheckDuplicateData(pRegioCode, pEmpCode, pDistCode, pSSCode, row, ChkType) {
            var Item = "";
            if (pRegioCode != "") {
                Item = pRegioCode.split("-")[2].trim();
            }
            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            $('#tblClaim  > tbody > tr').each(function (row1, tr) {
                var RegionCode = $("input[name='AutoRegion']", this).val() != "" ? $("input[name='AutoRegion']", this).val().split("-")[2].trim() : "";
                var EmpCode = $("input[name='AutoEmpName']", this).val() != "" ? $("input[name='AutoEmpName']", this).val().split("-")[2].trim() : "";
                var DistCode = $("input[name='AutoDistName']", this).val() != "" ? $("input[name='AutoDistName']", this).val().split("-")[2].trim() : "";
                var SSCode = $("input[name='AutoSSName']", this).val() != "" ? $("input[name='AutoSSName']", this).val().split("-")[2].trim() : "";

                var LineNum = $("input[name='hdnLineNum']", this).val();
                var RgnId = $("input[name='hdnRegionId']", this).val();
                var EmpId = $("input[name='hdnEmpId']", this).val();
                var DistId = $("input[name='hdnDistId']", this).val();
                var SSId = $("input[name='hdnSSId']", this).val();

                if (ChkType == 1) {
                    if (RgnId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == RegionCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoRegion' + ind).val("");
                                $('#hdnRegionId' + ind).val(0);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                errormsg = 'Region is already set for = ' + pRegioCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 2) {

                    if (EmpCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (pEmpCode.split("-")[2].trim() == EmpCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoEmpName' + row).val('');
                                // $('#hdnEmpId' + ind).val(0);
                                errormsg = 'Employee is already set for = ' + pEmpCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 3) {
                    if (DistId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (pDistCode.split("-")[2].trim() == DistCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDistName' + row).val('');
                                errormsg = 'Distributor is already set = ' + pDistCode + ' at row : ' + rowCnt_Claim;
                                return false;
                            }
                        }
                    }
                }
                else {
                    if (ChkType == 4) {
                        if (SSId != "") {
                            if (parseInt(row) != parseInt(LineNum)) {
                                if (pSSCode.split("-")[2].trim() == SSCode) {
                                    cnt = 1;
                                    errRow = row;
                                    $('#AutoSSName' + row).val('');
                                    errormsg = 'Super Stockist is already set for = ' + pSSCode + ' at row : ' + rowCnt_Claim;
                                    return false;
                                }
                            }
                        }
                    }
                }
                //}
                rowCnt_Claim++;
                //}
            });

            if (cnt == 1) {
                //$('#AutoCustCode' + row).val('');
                if (ChkType == 1) {
                    $('#AutoRegion' + row).val("");
                }
                else if (ChkType == 2) {
                    $('#AutoEmpName' + row).val('');
                }
                else if (ChkType == 3) {
                    $('#AutoDistName' + row).val('');
                }
                else {
                    $('#AutoSSName' + row).val('');
                }
                ClearClaimRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowClaim').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function ClearClaimRow(row) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblClaim > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var RegionCode = $("input[name='AutoRegion']", this).val();
                if (RegionCode == "") {
                    //$(this).remove();
                }
                cnt++;
                rowCnt_Claim++;
            });

            if (cnt > 1) {
                var rowCnt_Claim = 1;
                $('#tblClaim > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var ClaimLockingId = $("input[name='hdnClaimLockingId']", this).val();
                        var RegionName = $("input[name='AutoRegion']", this).val();
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        var DistName = $("input[name='AutoDistName']", this).val();
                        var SSName = $("input[name='AutoSSName']", this).val();
                        var Days = $("input[name='hdnDaysId']", this).val();
                        if (RegionName == "" && EmpName == "" && DistName == "" && SSName == "" && Days == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblClaim > tbody > tr').each(function (row, tr) {
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
            $('#tblClaim  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                $(this).remove();
            });

            var IsValid = true;
            $.ajax({
                url: 'ClaimLockingMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ OptionId: $('.ddlOption').val() }),
                success: function (result) {
                    $.unblockUI();
                    if (result.d[0].length == 0) {
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
                            $('#tblClaim  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var trHTML = '';
                            var row = 1;
                            $('#CountRowClaim').val(0);
                            var ind = $('#CountRowClaim').val();
                            //  ind = parseInt(ind) + 1;

                            $('#CountRowClaim').val(ind);
                            var ind = 0;

                            // $('#CountRowClaim').val(0);
                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowClaim').val();
                                $('#chkEdit' + row).click();
                                $('#chkEdit' + row).prop("checked", false);

                                $('#AutoRegion' + row).val(items[i].Region);
                                $('#AutoEmpName' + row).val(items[i].EmpName);
                                $('#AutoDistName' + row).val(items[i].DistName);
                                $('#AutoSSName' + row).val(items[i].SSName);
                                $('#days' + row).val(items[i].Days);

                                // $('#AutoCustName' + row).val(items[i].CustomerName);                               

                                if (items[i].IsActive == false) {
                                    $('#chkIsActive' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkIsActive' + row).prop("checked", true);
                                }

                                $('#tdCreatedBy' + row).text(items[i].CreatedBy);
                                $('#tdCreatedDate' + row).text(items[i].CreatedDate);
                                $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                $('#tdUpdateDate' + row).text(items[i].UpdatedDate);
                                $('#hdnClaimLockingId' + row).val(items[i].OCLPMID);
                                $('#hdnRegionId' + row).val(items[i].RegionId);
                                $('#hdnEmpId' + row).val(items[i].EmpId);
                                $('#hdnDistId' + row).val(items[i].DistributorId);
                                $('#hdnSSId' + row).val(items[i].SSID);
                                $('.chkEdit').prop("checked", false);
                                $('.btnEdit').click();
                            }
                        }
                        else {
                            $('#tblClaim  > tbody > tr').each(function (row1, tr) {
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

        function GetReport() {
            var option = $(".ddlOption").val();
            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();

                $('.gvClaimLockingHistory tbody').empty();
                $.ajax({
                    url: 'ClaimLockingMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','OptionId': '" + $('.ddlOption').val() + "'}",
                    success: function (result) {
                        if (result.d[0] == "" || result.d[0] == undefined) {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoRegion']", this).val() == "";
                            return false;
                        }
                        else {
                            var ReportData = JSON.parse(result.d[0]);
                            if (ReportData[0].OptionId == 1) {
                                $('#gvClaimLockingHistory').find('th:nth-child(5)').hide();
                                $('.tdSS').hide();
                                $('.thss').hide();
                                $('.tdDist').show();
                                $('.thDist').show();
                                $('.tdRegion').show();
                                $('.thRegion').show();
                            }
                            else if (ReportData[0].OptionId == 2) {
                                $('#gvClaimLockingHistory').find('th:nth-child(4)').hide();
                                $('.tdDist').hide();
                                $('.thDist').hide();
                                $('.tdSS').show();
                                $('.thss').show();
                                $('.tdRegion').show();
                                $('.thRegion').show();
                            }
                            else {
                                $('#gvClaimLockingHistory').find('th:nth-child(4)').hide();
                                $('#gvClaimLockingHistory').find('th:nth-child(5)').hide();
                                $('.tdSS').hide();
                                $('.tdDist').hide();
                                $('.tdRegion').hide();
                                $('.thss').hide();
                                $('.thDist').hide();
                                $('.tdRegion').hide();
                                $('.thRegion').hide();
                            }
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].Region + "</td>"
                                        + "<td class='tdRegion'>" + ReportData[i].EmpName + "</td>"
                                        + "<td class='tdDist'>" + ReportData[i].Distributor + "</td>"                                        
                                        + "<td class='tdSS'>" + ReportData[i].SSName + "</td>"
                                        + "<td>"+ ReportData[i].Days +"</td>"
                                        + "<td>" + ReportData[i].IsActive + "</td>"
                                         + "<td>" + ReportData[i].IsDeleted + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"    

                                $('.gvClaimLockingHistory > tbody').append(str);

                                
                                if (ReportData[0].OptionId == 1) {
                                    $('.tdDist').show();
                                    $('.tdSS').hide();
                                    $('.tdRegion').show();
                                }
                                else if (ReportData[0].OptionId == 2) {
                                    $('.tdDist').hide();
                                    $('.tdSS').show();
                                    $('.tdRegion').show();
                                }
                                else {
                                    $('.tdRegion').hide();
                                    $('.tdSS').hide();
                                    $('.tdDist').hide();
                                }
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvClaimLockingHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "15px", "aTargets": 2 });                   
                    aryJSONColTable.push({ "width": "17px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "15px",  "aTargets": 4 });
                    aryJSONColTable.push({ "width": "5px",  "sClass": "dtbodyRight","aTargets": 5 });//"sClass": "dtbodyLeft",
                    aryJSONColTable.push({ "width": "7px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "10px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "10px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "150px","sClass": "dtbodyCenter", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter","aTargets": 11 });                   

                    $('.gvClaimLockingHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '58vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{
                            extend: 'copy',
                            exportOptions: {
                                columns: ':visible',
                                search: 'applied',
                                order: 'applied'
                            },
                            footer: true
                        },
                        {
                            extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                           
                            customize: function (csv) {
                                var data = $("#lnkTitle").text() + '\n';
                                data += 'Option,' + $('.ddlOption option:selected').text() + '\n';
                                data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                //data += 'UserId,' + $('.hdnUserName').val() + '\n';
                               // data += 'Created on,' + jsDate.toString() + '\n';
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

                                sheet = ExportXLS(xlsx, 5);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);                                
                                var r2 = Addrow(3, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                             //   var r3 = Addrow(4, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                             //   var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2   + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                                  //  { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                   // { text: 'Created On : ' + jsDate.toString() + "\n" },
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
                                  var option = $(".ddlOption").val();
                 
                                var rowCount = doc.content[0].table.body.length;
                                for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                    doc.content[0].table.body[i][0].alignment = 'center';
                                   
                                  
                                   // doc.content[0].table.body[i][7].alignment = 'center';
                                    if (option == 1 || option == 2) {
                                        doc.content[0].table.body[i][4].alignment = 'right';
                                        doc.content[0].table.body[i][2].alignment = 'left';
                                         doc.content[0].table.body[i][7].alignment = 'left';
                                         doc.content[0].table.body[i][8].alignment = 'center';
                                         doc.content[0].table.body[i][9].alignment = 'left';
                                         doc.content[0].table.body[i][10].alignment = 'center';
                                         doc.content[0].table.body[0][6].alignment = 'left';

                                        }
                                    else
                                    {
                                        doc.content[0].table.body[i][2].alignment = 'right';
                                     //   doc.content[0].table.body[i][3].alignment = 'left';
                                        doc.content[0].table.body[i][6].alignment = 'center';
                                        doc.content[0].table.body[i][4].alignment = 'left';
                                        doc.content[0].table.body[i][8].alignment = 'center';
                                        doc.content[0].table.body[i][7].alignment = 'left';
                                       //  doc.content[0].table.body[i][9].alignment = 'center';
                                    }                                   

                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                               
                                doc.content[0].table.body[0][3].alignment = 'left';
                              
                                doc.content[0].table.body[0][5].alignment = 'right';
                              
                              //  doc.content[0].table.body[0][7].alignment = 'left';
                              
                                
                                //doc.content[0].table.body[0][9].alignment = 'left';
                               // doc.content[0].table.body[0][10].alignment = 'left';                              
                            }
                        }]
                    });
                }
            }
        }

        function ClearControls() {

            $('.divClaimEntry').attr('style', 'display:none;');
            $('.divClaimReport').attr('style', 'display:none;');
            $('.divMissData').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblClaim tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvClaimLockingHistory')) {
                $('.gvClaimLockingHistory').DataTable().destroy();
            }

            $('.gvClaimLockingHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divClaimReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');

                 var option = $(".ddlOption").val();
                 if (option == 1) {
                            $('.tdSS').hide();
                                $('.thss').hide();
                                $('.tdDist').show();
                                $('.thDist').show();
                                $('.thRegion').show();
                                $('.tdRegion').show();
                            }
                       else   if (option == 2) {
                                $('.tdSS').show();
                                $('.thss').show();
                                $('.tdDist').hide();
                                $('.thDist').hide();
                                $('.thRegion').show();
                                $('.tdRegion').show();
            }
            else
            {                    
                               $('.tdSS').hide();
                                $('.thss').hide();
                                $('.tdDist').hide();
                                $('.thDist').hide();
                                $('.thRegion').hide();
                                $('.tdRegion').hide();

                    }
            }
            else {
                $('.divClaimEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowClaim').val(0);
                FillData();
                AddMoreRow();
            }

        }

        function RemoveClaimLockingRow(row) {

            var OCLPMID = $('table#tblClaim tr#trClaim' + row).find(".hdnClaimLockingId").val();
            $('table#tblClaim tr#trClaim' + row).find(".IsChange").val("1");
            $('table#tblClaim tr#trClaim' + row).remove();
            $('table#tblClaim tr#trClaim' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = OCLPMID + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblClaim tr#trClaim' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }

        function Cancel() {
            window.location = "../Master/ClaimLockingMaster.aspx";
        }


        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowClaim').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
            //CheckDuplicateCust($(txt).parent().parent().find("input[name='AutoCustCode']").val(), Number($(txt).parent().parent().find("input[name='hdnLineNum']").val()));
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
            $('#tblClaim  > tbody > tr').each(function (row, tr) {
                var Days = $("input[name='days']", this).val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                if (IsChange == "1") {
                    if (Days == "" || Days == 0 ) {
                        ModelMsg("Please enter days", 3);
                        $.unblockUI();
                        IsValid = false;
                        return false;
                    }
                }
            });
            if (!IsValid) {
                $.unblockUI();
                return false;
            }
            $('#tblClaim  > tbody > tr').each(function (row, tr) {
                var RegionName = $("input[name='AutoRegion']", this).val().split('-').pop().trim();//$("input[name='AutoRegion']", this).val();
                var EmpName = $("input[name='AutoEmpName']", this).val().split('-').pop().trim();// $("input[name='AutoEmpName']", this).val();
                var DistName = $("input[name='AutoDistName']", this).val().split('-').pop().trim();
                var SSName = $("input[name='AutoSSName']", this).val().split('-').pop().trim();
                var Days = $("input[name='days']", this).val();
                //var EmpID = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();

                var RgnId = $("input[name='hdnRegionId']", this).val().trim();
                var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                var DistId = $("input[name='hdnDistId']", this).val().trim();
                var SSId = $("input[name='hdnSSId']", this).val().trim();
                var IsDeleted = $('#hdnIsRowDeleted').val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                            
                if ((RegionName != "" || EmpName != "" || DistName != '' || SSName != '') && (IsChange == "1" || IsDeleted == 1) && (Days != "" || Days != 0)) {                   

                    totalItemcnt = 1;
                    var ClaimLockingId = $("input[name='hdnClaimLockingId']", this).val().trim();
                    var RgnId = $("input[name='hdnRegionId']", this).val().trim();
                    var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                    var DistId = $("input[name='hdnDistId']", this).val().trim();
                    var SSId = $("input[name='hdnSSId']", this).val().trim();
                    var DaysId = $("input[name='hdnDaysId']", this).val().trim();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var IPAddress = $("#hdnIPAdd").val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    var obj = {
                        CliamLockingId: ClaimLockingId,
                        RegionId: RegionName,
                        EmpId: EmpName,
                        DistId: DistId,
                        SSId: SSId,
                        DaysId: Days,
                        IsActive: IsActive,
                        IPAddress: IPAddress,
                        IsChange: IsChange
                    };
                    TableData_Claim.push(obj);
                }

                rowCnt_Claim++;
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

            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'ClaimLockingMaster.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputClaim: ClaimProcessData, OptionId: $('.ddlOption').val(), IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val() }),
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

    </script>
    <style>
        .days {
            height: 25px !important;
        }

        .ui-widget {
            font-size: 12px;
        }

        .ui-datepicker {
            z-index: 9 !important;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }
        .days {
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

        .ui-autocomplete {
            position: absolute;
        }
        /*ul.ui-autocomplete { top: 217.125px !important;
            z-index: 100000000;
            position: absolute;
        }*/
        /*body {
            overflow:hidden;
        }*/
        /*table#gvClaimLockingHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
        }*/

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
        table.dataTable tbody th {
            text-align:left;
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

        table.gvClaimLockingHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        /*table.gvClaimLockingHistory td:nth-child(1), table.gvClaimLockingHistory td:nth-child(4), table.gvClaimLockingHistory td:nth-child(5) {
            text-align: left;
        }

        table.gvClaimLockingHistory td:nth-child(6), table.gvClaimLockingHistory td:nth-child(7) {
            text-align: left;
        }*/
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="1" onchange="ShowDistOrSSOnChange();">
                            <asp:ListItem Value="1">Distributor</asp:ListItem>
                            <asp:ListItem Value="2">Super Stockist</asp:ListItem>
                            <asp:ListItem Value="3">Back Office</asp:ListItem>
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
            </div>
            <input type="hidden" id="CountRowClaim" />
            <div id="divClaimEntry" class="divClaimEntry" runat="server" style="max-height: 80vh; position: absolute; overflow: hidden;">
                <table id="tblClaim" class="table table-bordered" border="1" tabindex="8" style="width: 100%; border-collapse: collapse; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 2%; text-align: center;">Sr</th>
                            <th style="width: 3.5%">Edit</th>
                            <th style="width: 3.5%">Delete</th>
                            <th style="width: 10%">Region</th>
                            <th style="width: 9%">Employee</th>
                            <th style="width: 9%">Distributor</th>
                            <th style="width: 9%">Super Stockist</th>
                            <th style="width: 4%">Days</th>
                            <th style="width: 3%;">Active</th>
                            <th style="width: 7%;">Entry By</th>
                            <th style="width: 5%;">Entry Date/Time</th>
                            <th style="width: 7%;">Updated By</th>
                            <th style="width: 5%;">Update Date/Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divClaimReport" class="divClaimReport" style="max-height: 30vh; overflow-y: auto;">
                <table id="gvClaimLockingHistory" class="gvClaimLockingHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="text-align: center; width: 2%;">Sr</th>
                            <th style="width: 10%" class="thRegion">Region</th>
                            <th style="width: 10%">Employee</th>
                            <th style="width: 10%" class="thDist">Distritutor</th>
                            <th style="width: 10%" class="thss">Super Stockist</th>
                            <th style="width: 3%">Days</th>
                            <th style="width: 3%;">Active</th>
                             <th style="width: 3%;">Deleted</th>
                            <th style="width: 5%;">Entry By</th>
                            <th style="width: 5%;">Entry Date/Time</th>
                            <th style="width: 5%;">Update By</th>
                            <th style="width: 5%;">Update Date/Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
