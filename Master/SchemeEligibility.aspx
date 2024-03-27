<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="SchemeEligibility.aspx.cs" Inherits="Master_SchemeEligibility" %>

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
      //  var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
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
            $("#tblScheme").tableHeadFixer('80vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            FillData();
            var clicked = false;
            //  var OptionId = $('.ddlOption').val();
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
            $(".txtCode").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: "SchemeEligibility.aspx/LoadScheme",
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "','OptionId': '" + ($('.ddlOption').val() != '' ? $('.ddlOption').val() : 0) + "'}",
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
                    $(".txtCode").val(ui.item.value);
                },
                change: function (event, ui) {
                    if (!ui.item) {

                        $('.txtCode').val("");
                    }
                },
                minLength: 1
            });
            HideShowTableRowColumn();
        });
        function HideShowTableRowColumn() {
            var OptionId = $('.ddlOption').val();
            if (OptionId == 2) {
                $('.thElgDays').show();
                $('.tdElgDays').show();
                $('.thElgQty').hide();
                $('.tdElgQty').hide();


                $('.thElgHist').show();
                $('.tdEleHist').show();
                $('.thQPSHist').hide();
                $('.tdQpsHist').hide();
            }
            else {
                $('.thElgDays').hide();
                $('.tdElgDays').hide();
                $('.thElgQty').show();
                $('.tdElgQty').show();

                $('.thElgHist').hide();
                $('.tdEleHist').hide();
                $('.thQPSHist').show();
                $('.tdQpsHist').show();
            }
        }
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
        function AddMoreRow() {

            $('table#tblScheme tr#NoROW').remove();  // Remove NO ROW


            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowScheme').val();
            ind = parseInt(ind) + 1;
            $('#CountRowScheme').val(ind);

            var str = "";
            str = "<tr id='trCustomer" + ind + "'>"
                  + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                 + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveSchemeRow(" + ind + ");' /></td>"
                + "<td><input type='text' id='AutoDistRegion" + ind + "' name='AutoDistRegion' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input type='text' id='AutoDistCode" + ind + "' name='AutoDistCode' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input type='text' id='AutoDealerCode" + ind + "' name='AutoDealerCode' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input type='checkbox' id='chkInclExcl" + ind + "' name='chkInclExcl' onchange='ChangeData(this);' class='form-control checkbox'/></td>"

                + "<td class='tdElgDays'><input type='text' id='txtElgDays" + ind + "' name='txtElgDays' maxlength='4' onchange='ChangeData(this);' class='form-control dtbodyRight allownumericwithoutdecimal search' /></td>"

                + "<td class='tdElgQty'><input type='text' id='txtElgQty" + ind + "' name='txtElgQty' maxlength='4' onchange='ChangeData(this);' class='form-control dtbodyRight allownumericwithoutdecimal search' /></td>"

            + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);' class='form-control checkbox'/></td>"
            + "<td id='tdCreateOn" + ind + "' class='tdCreateOn'></td>"
            + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
            + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn'></td>"
            + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
            + "<input type='hidden' class='hdnRegionID' id='hdnRegionID" + ind + "' name='hdnRegionID' /></td>"
            + "<input type='hidden' class='hdnDistID' id='hdnDistID" + ind + "' name='hdnDistID' /></td>"
            + "<input type='hidden' class='hdnDealerID' id='hdnDealerID" + ind + "' name='hdnDealerID' /></td>"
            + "<input type='hidden' class='hdnScmELID' id='hdnScmELID" + ind + "' name='hdnScmELID' /></td>"
            + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
             + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
             + "<input type='hidden' class='IsDeleted' id='IsDeleted" + ind + "' name='IsDeleted' value='0' /></td>"
            + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />"

            $('#tblScheme > tbody').append(str);
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            //---------------Distributor Region----------
            $('#AutoDistRegion' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "SchemeEligibility.aspx/GetDistRegionCurrHierarchy",
                        type: 'POST',
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "'}",
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
                    $('#AutoDistRegion' + ind).val(ui.item.value);
                    $('#hdnRegionID' + ind).val(ui.item.value.split('-')[2].trim());
                    $('#AutoDistCode' + ind).val("");
                    $('#hdnDistID' + ind).val(0);
                    $('#AutoDealerCode' + ind).val("");
                    $('#hdnDealerID' + ind).val(0);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoDistRegion' + ind).val("");
                        $('#hdnRegionID' + ind).val(0);
                        $('#AutoDistCode' + ind).val("");
                        $('#hdnDistID' + ind).val(0);
                        $('#AutoDealerCode' + ind).val("");
                        $('#hdnDealerID' + ind).val(0);
                    }
                },
                minLength: 1
            });

            HideShowTableRowColumn();

            $('#AutoDistRegion' + ind).on('change keyup', function () {
                if ($('#AutoDistRegion' + ind).val() == "") {
                    ClearDistRegionRow(ind);
                }
            });

            $('#AutoDistRegion' + ind).on('blur', function (e, ui) {
                if ($('#AutoDistRegion' + ind).val().trim() != "") {
                    if ($('#AutoDistRegion' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Region", 3);
                        $('#AutoDistRegion' + ind).val("");
                        $('#hdnRegionID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoDistRegion' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateRegion($('#AutoDistRegion' + ind).val().trim(), ind);
                }
                //else {
                //    $('#AutoDistRegion' + ind).val("");
                //    $('#hdnRegionID' + ind).val(0);
                //}
            });

            //-------------Distributor-------------

            $("#AutoDistCode" + ind).autocomplete({
                source: function (request, response) {
                    var stateID = $("#AutoDistRegion" + ind).val() != "" && $("#AutoDistRegion" + ind).val() != undefined ? $("#AutoDistRegion" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: "SchemeEligibility.aspx/GetDistributorCurrHierarchy",
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "','StateID': '" + stateID + "'}",
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
                    $('#AutoDistCode' + ind).val(ui.item.value);
                    $('#hdnDistID' + ind).val(ui.item.value.split('-')[2].trim());
                    $('#AutoDealerCode' + ind).val("");
                    $('#hdnDealerID' + ind).val(0);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoDistCode' + ind).val("");
                        $('#hdnDistID' + ind).val(0);
                        $('#AutoDealerCode' + ind).val("");
                        $('#hdnDealerID' + ind).val(0);
                    }
                },
                minLength: 1
            });

            $('#AutoDistCode' + ind).on('change keyup', function () {
                if ($('#AutoDistCode' + ind).val() == "") {
                    ClearDistRow(ind);
                }
            });
            $('#AutoDistCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoDistCode' + ind).val().trim() != "") {
                    if ($('#AutoDistCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Distributor", 3);
                        $('#AutoDistCode' + ind).val("");
                        $('#hdnDistID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoDistCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateDist($('#AutoDistCode' + ind).val().trim(), ind);
                }
                //else {
                //    $('#AutoDistCode' + ind).val("");
                //    $('#hdnDistID' + ind).val(0);
                //}
            });

            var lineNum = 1;
            $('#tblScheme > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
            //---------------Dealer Code & Name---------------
            $('#AutoDealerCode' + ind).autocomplete({
                source: function (request, response) {
                    var stateID = $("#AutoDistRegion" + ind).val() != "" && $("#AutoDistRegion" + ind).val() != undefined ? $("#AutoDistRegion" + ind).val().split("-")[2].trim() : "0";
                    var distID = $("#AutoDistCode" + ind).val() != "" && $("#AutoDistCode" + ind).val() != undefined ? $("#AutoDistCode" + ind).val().split("-")[2].trim() : "0";

                    $.ajax({
                        type: "POST",
                        url: "SchemeEligibility.aspx/GetDealerCurrHierarchy",
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "','StateID': '" + stateID + "','DistID': '" + distID + "'}",
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
                    $('#AutoDealerCode' + ind).val(ui.item.value + " ");
                    $('#hdnDealerID' + ind).val(ui.item.value.split('-')[2].trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoDealerCode' + ind).val("");
                        $('#hdnDealerID').val(0);
                    }
                },
                minLength: 1
            });

            $('#AutoDealerCode' + ind).on('change keyup', function () {
                if ($('#AutoDealerCode' + ind).val() == "") {
                    ClearDealerRow(ind);
                }
            });

            $('#AutoDealerCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoDealerCode' + ind).val().trim() != "") {
                    if ($('#AutoDealerCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Dealer", 3);
                        $('#AutoDealerCode' + ind).val("");
                        $('#hdnDealerID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoDealerCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateCustomer($('#AutoDealerCode' + ind).val().trim(), ind);
                }
                //else {
                //    $('#AutoDealerCode' + ind).val("");
                //    $('#hdnDealerID' + ind).val(0);
                //}
            });

            $(".allownumericwithoutdecimal").on("keypress keyup", function (event) {
                $(this).val($(this).val().replace(/[^\d].+/, ""));
                if ((event.which < 48 || event.which > 57)) {
                    event.preventDefault();
                }
            });
        }

        function RemoveSchemeRow(row) {
            $('table#tblScheme tr#trCustomer' + row).remove();
            $('table#tblScheme tr#trCustomer' + row).find(".IsDeleted").val("1");
            $('table#tblScheme tr#trCustomer' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }

        function CheckDuplicateRegion(CustCode, row) {

            var Item = CustCode.split("-")[0].trim() + " - " + CustCode.split("-")[1].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblScheme  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoDistRegion']", this).val().split("-").length == 3) {
                    var CustCode = $("input[name='AutoDistRegion']", this).val().split("-")[0].trim() + " - " + $("input[name='AutoDistRegion']", this).val().split("-")[1].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDistRegion' + row).val('');
                                $('#hdnRegionID' + row).val(0);
                                $('#chkInclExcl' + row).prop('checked', false);
                                $('#chkInclExcl' + row).attr("disabled", false);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                $('#txtElgDays' + row).text('');
                                errormsg = 'Region = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                //}

                rowCnt_Customer++;
            });

            if (cnt == 1) {
                $('#AutoDistRegion' + row).val('');
                ClearDistRegionRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowScheme').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function CheckDuplicateDist(CustCode, row) {

            var Item = CustCode.split("-")[0].trim() + " - " + CustCode.split("-")[1].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblScheme  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoDistCode']", this).val().split("-").length == 3) {
                    var CustCode = $("input[name='AutoDistCode']", this).val().split("-")[0].trim() + " - " + $("input[name='AutoDistCode']", this).val().split("-")[1].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDistCode' + row).val('');
                                $('#hdnDistID' + row).val(0);

                                $('#chkInclExcl' + row).prop('checked', false);
                                $('#chkInclExcl' + row).attr("disabled", false);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                $('#txtElgDays' + row).text('');
                                errormsg = 'Distributor = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                //}

                rowCnt_Customer++;
            });

            if (cnt == 1) {
                $('#AutoDistCode' + row).val('');
                ClearDistRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowScheme').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function ClearDistRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblScheme > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDistCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblScheme > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDistCode']", this).val();
                        if (CustCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblScheme > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }
        function ClearDealerRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblScheme > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDealerCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblScheme > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDealerCode']", this).val();
                        if (CustCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblScheme > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }
        function CheckDuplicateCustomer(CustCode, row) {

            var Item = CustCode.split("-")[0].trim() + " - " + CustCode.split("-")[1].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblScheme  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoDealerCode']", this).val().split("-").length == 3) {
                    var CustCode = $("input[name='AutoDealerCode']", this).val().split("-")[0].trim() + " - " + $("input[name='AutoDealerCode']", this).val().split("-")[1].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDealerCode' + row).val('');
                                $('#hdnDealerID' + row).val(0);
                                $('#chkInclExcl' + row).prop('checked', false);
                                $('#chkInclExcl' + row).attr("disabled", false);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                $('#txtElgDays' + row).text('');
                                errormsg = 'Dealer = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                //}

                rowCnt_Customer++;
            });

            if (cnt == 1) {
                $('#AutoDealerCode' + row).val('');
                ClearDealerRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowScheme').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function ClearDistRegionRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblScheme > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDistRegion']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblScheme > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDistRegion']", this).val();
                        if (CustCode == "") {
                            //$(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblScheme > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function ClearDistRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblScheme > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDistCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblScheme > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDistCode']", this).val();
                        if (CustCode == "") {
                            //$(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblScheme > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function ClearDealerRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblScheme > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDealerCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblScheme > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDealerCode']", this).val();
                        if (CustCode == "") {
                            //$(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblScheme > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function Cancel() {
            window.location = "../Master/SchemeEligibility.aspx";
        }

        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
        }

        function btnSubmit_Click() {
            var SchemeID = $('.txtCode').val().split('-')[0].trim();
            var OptionId = $('.ddlOption').val();
            if (SchemeID > 0) {
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

                $('#tblScheme  > tbody > tr').each(function (row, tr) {
                    //if (CustCode != "") {
                    totalItemcnt = 1;
                    var DealerID = $("input[name='hdnDealerID']", this).val();
                    var DistRegionID = $("input[name='hdnRegionID']", this).val();
                    var DistID = $("input[name='hdnDistID']", this).val();
                    var ScmELGID = $("input[name='hdnScmELID']", this).val();
                    var IsInclExcl = $("input[name='chkInclExcl']", this).is(':checked');
                    var EligibleCount = $("input[name='txtElgDays']", this).val();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    var IsDeleted = $("input[name='IsDeleted']", this).is(':checked');
                    var QPSQty = $("input[name='txtElgQty']", this).val();
                    var obj = {
                        DealerID: DealerID,
                        DistRegionID: DistRegionID,
                        DistID: DistID,
                        ScmELGID: ScmELGID,
                        IsInclExcl: IsInclExcl,
                        EligibleCount: EligibleCount,
                        QPSQty: QPSQty,
                        IsChange: IsChange,
                        IsDeleted: IsDeleted,
                        IsActive: IsActive,
                    };
                    TableData_Customer.push(obj);
                    //}
                    rowCnt_Customer++;
                    if (DealerID != 0 || DistRegionID != 0 || DistID != 0) {
                        if (OptionId == 2 ) {
                            if ((EligibleCount == 0 || EligibleCount == "") && IsInclExcl == true) {
                                ModelMsg("Eligible Count should not be 0 at row : " + rowCnt_Customer, 3);
                                IsValid = false;
                            }
                        }
                        else {
                            if ((QPSQty == 0 || QPSQty == "") && IsInclExcl == true) {
                                ModelMsg("QPS Qty should not be 0 at row : " + rowCnt_Customer, 3);
                                IsValid = false;
                            }
                        }
                    }
                });

                var CustomerData = JSON.stringify(TableData_Customer);

                var successMSG = true;

                if (IsValid) {
                    var sv = $.ajax({
                        url: 'SchemeEligibility.aspx/SaveData',
                        type: 'POST',
                        //async: false,
                        dataType: 'json',
                        // traditional: true,
                        data: JSON.stringify({ hidJsonInputCustomer: CustomerData, SchemeID: SchemeID, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), OptionId: OptionId }),
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
            else {
                alert('Please select proper scheme');
                return false;
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
                var SchemeID = $('.txtCode').val().split('-').pop().trim();
                var OptionId = $('.ddlOption').val();
                //ClearControls();

                $.ajax({
                    url: 'SchemeEligibility.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','SchemeID': '" + SchemeID + "','OptionId': '" + OptionId + "'}",
                    success: function (result) {
                        if (result.d[0] == "" || result.d[0] == undefined) {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoCustCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].SchemeID + "</td>"
                                        + "<td>" + ReportData[i].Region + "</td>"
                                        + "<td>" + ReportData[i].DistCode + "</td>"
                                        + "<td>" + ReportData[i].DealerCode + "</td>"
                                        + "<td>" + ReportData[i].Include + "</td>"
                                        + "<td class='tdEleHist'>" + ReportData[i].ElgCount + "</td>"
                                          + "<td class='tdQpsHist'>" + ReportData[i].QPSQty + "</td>"
                                        + "<td>" + ReportData[i].Active + "</td>"
                                        + "<td>" + ReportData[i].Deleted + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td></tr>"

                                $('.gvCustHistory > tbody').append(str);
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });
                HideShowTableRowColumn();
                if ($('.gvCustHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "25px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "25px", "sClass": "dtbodyRight", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "160px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "340px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "340px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "35px",  "aTargets": 8 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyCenter", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "150px","aTargets": 11 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyCenter", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "150px",  "aTargets": 13 });

                    $('.gvCustHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '55vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy',  footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   data += 'Option,' + (($('.ddlOption option:Selected').val() > 0 && $('.ddlOption option:Selected').val() != "") ? $('.ddlOption option:Selected').text() : "All") + '\n';
                                   data += 'Scheme,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All") + '\n';
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
                               extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               exportOptions: {
                                   columns: ':visible',
                               },
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 6);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r6 = Addrow(2, [{ key: 'A', value: 'Option' }, { key: 'B', value: ($('.ddlOption option:Selected').val() > 0 && $('.ddlOption option:Selected').val() != "" ? $('.ddlOption option:Selected').text() : "All") }]);
                                   var r1 = Addrow(3, [{ key: 'A', value: 'Scheme' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All") }]);
                                   var r2 = Addrow(4, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                   var r3 = Addrow(5, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r4 = Addrow(6, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r6 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc.styles.tableFooter.fontSize = 7;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                      { text: $("#lnkTitle").text() + '\n' },
                                                        { text: 'Option : ' + $('.ddlOption option:Selected').text() + "\n" },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                       { text: 'Scheme : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All \n") },
                                                       { text: 'With History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False" + "\n") }
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
                                       doc.content[0].table.body[i][1].alignment = 'right';
                                       doc.content[0].table.body[i][6].alignment = 'right';
                                       doc.content[0].table.body[i][9].alignment = 'center';
                                       doc.content[0].table.body[i][11].alignment = 'center';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'right';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'left';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'right';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                                   doc.content[0].table.body[0][8].alignment = 'left';
                                   doc.content[0].table.body[0][9].alignment = 'center';
                                   doc.content[0].table.body[0][10].alignment = 'left';
                                   doc.content[0].table.body[0][11].alignment = 'center';
                                   doc.content[0].table.body[0][12].alignment = 'left';
                               }
                           }]
                    });
                }
            }
        }

        function ClearControls() {

            HideShowTableRowColumn();
            $('.divCustEntry').attr('style', 'display:none;');
            $('.divCustReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblScheme tbody').empty();
            $('.txtCode').val('');
            if ($.fn.DataTable.isDataTable('.gvCustHistory')) {
                $('.gvCustHistory').DataTable().destroy();
            }
            $('.gvCustHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divCustReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divCustEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowScheme').val(0);
                //AddMoreRow();
            }
        }
        function ClearSchemeControls() {
            HideShowTableRowColumn();
            $('.divCustEntry').attr('style', 'display:none;');
            $('.divCustReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblScheme tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvCustHistory')) {
                $('.gvCustHistory').DataTable().destroy();
            }
            $('.gvCustHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divCustReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divCustEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowScheme').val(0);
                FillData();
                //AddMoreRow();
            }
        }
        function FillData() {
            var IsValid = true;

            var SchemeID = $('.txtCode').val().split('-')[0].trim();
            var OptionId = $('.ddlOption').val();
            if ($('.txtCode').val() != '' && SchemeID != '' && $.isNumeric(SchemeID)) {
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
                    url: 'SchemeEligibility.aspx/LoadData',
                    type: 'POST',
                    dataType: 'json',
                    data: "{ 'SchemeID': '" + (SchemeID != '' ? SchemeID : 0) + "','OptionId': '" + (OptionId != '' ? OptionId : 0) + "'}",
                    contentType: 'application/json; charset=utf-8',
                    success: function (result) {
                        $.unblockUI();

                        console.log(result.d);

                        if (result.d == "") {
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
                        else if ($('.txtCode').val() == "") {
                            $.unblockUI();
                            var ErrorMsg = result.d[0].split('#')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            event.preventDefault();
                            return false;
                        }
                        else {
                            var items = result.d[0];
                            if (items.length > 0) {
                                $('#tblScheme  > tbody > tr').each(function (row1, tr) {
                                    // post table's data to Submit form using Json Format
                                    $(this).remove();
                                });
                                var row = 1;
                                $('#CountRowScheme').val(0);

                                for (var i = 0; i < items.length; i++) {
                                    AddMoreRow();

                                    row = $('#CountRowScheme').val();
                                    $('#chkEdit' + row).click();
                                    $('#chkEdit' + row).prop("checked", false);

                                    $('#hdnScmELID' + row).val(items[i].ScmELID);
                                    $('#hdnRegionID' + row).val(items[i].RegionId);
                                    $('#hdnDistID' + row).val(items[i].DistID);
                                    $('#hdnDealerID' + row).val(items[i].DealerID);
                                    $('#AutoDistRegion' + row).val(items[i].RegionDesc);
                                    $('#AutoDistCode' + row).val(items[i].DistDesc);
                                    $('#AutoDealerCode' + row).val(items[i].DealerDesc);
                                    $('#txtElgDays' + row).val(items[i].EligibleCnt);
                                    $('#txtElgQty' + row).val(items[i].QPSQty);
                                    $('#IsDeleted' + row).val(items[i].IsDeleted);
                                    if (items[i].IsInclude == false) {
                                        $('#chkInclExcl' + row).prop("checked", false);
                                    }
                                    else {
                                        $('#chkInclExcl' + row).prop("checked", true);
                                    }
                                    if (items[i].IsActive == false) {
                                        $('#chkIsActive' + row).prop("checked", false);
                                    }
                                    else {
                                        $('#chkIsActive' + row).prop("checked", true);
                                    }
                                    $('#tdCreateBy' + row).text(items[i].CreatedBy);
                                    $('#tdCreateOn' + row).text(items[i].CreatedDate);
                                    $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                    $('#tdUpdateOn' + row).text(items[i].UpdatedDate);
                                    $('.chkEdit').prop("checked", false);
                                    $('.btnEdit').click();
                                }
                            }
                        }
                        AddMoreRow();
                        HideShowTableRowColumn();

                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $.unblockUI();
                        ModelMsg("Select Proper Scheme", 3);
                        $('.txtCode').val("");
                        event.preventDefault();
                        return false;
                    }
                });
            }
            //AddMoreRow();
        }

    </script>

    <style>
        .ui-widget {
            font-size: 12px;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
        }

        input.txtCompContri, input.txtDistContri {
            text-align: right;
        }

        td.txtSrNo {
            text-align: center;
        }

        table#gvSchemeHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
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

        table.gvSchemeHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        table.gvSchemeHistory td:nth-child(1), table.gvSchemeHistory td:nth-child(4), table.gvSchemeHistory td:nth-child(5) {
            text-align: center;
        }

        table.gvSchemeHistory td:nth-child(6), table.gvSchemeHistory td:nth-child(7) {
            text-align: right;
        }

        .search {
            background-color: lightyellow;
        }

        table.dataTable thead th, table.dataTable thead td {
            padding: 10px 5px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />

    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control " TabIndex="1" onchange="ClearControls()">
                            <asp:ListItem Text="On QPS Total Qty" Value="1" />
                            <asp:ListItem Text="On Invoice Counting" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Scheme" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox ID="txtCode" runat="server" TabIndex="2" Style="background-color: rgb(250, 255, 189);" CssClass="txtCode form-control" autocomplete="off" onchange="ClearSchemeControls();"></asp:TextBox>
                    </div>
                </div>
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

            <input type="hidden" id="CountRowScheme" />
            <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <table id="tblScheme" class="table table-bordered" border="1" tabindex="7" style="font-size: 11px">
                    <thead>
                        <tr class="table-header-gradient">
                            <th class="dtbodyCenter" style="width: 2%; text-align: center;">Sr</th>
                            <th style="width: 3.5%">Edit</th>
                            <th style="width: 3.5%">Delete</th>
                            <th class="dtbodyLeft" style="width: 10%">Distributor Region</th>
                            <th class="dtbodyLeft" style="width: 10%">Distributor Code & Name</th>
                            <th class="dtbodyLeft" style="width: 10%">Dealer Code & Name</th>
                            <th class="dtbodyLeft" style="width: 4%">Incl/Excl</th>
                            <th class="dtbodyLeft thElgDays" style="width: 3.7%">Eligible Count</th>
                            <th class="dtbodyLeft thElgQty" style="width: 3.7%">QPS Qty</th>
                            <th class="dtbodyLeft" style="width: 3%;">Active</th>
                            <th class="dtbodyCenter" style="width: 4%">Created Date/Time</th>
                            <th class="dtbodyLeft" style="width: 8%">Created By</th>
                            <th class="dtbodyCenter" style="width: 4%">Updated Date/Time</th>
                            <th class="dtbodyLeft" style="width: 8%">Updated By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divCustReport" class="divCustReport">
                <table id="gvCustHistory" class="gvCustHistory table table-bordered" style="width: 100%; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th class="dtbodyCenter">Sr</th>
                            <th class="dtbodyRight">Scheme</th>
                            <th class="dtbodyLeft">Distributor Region</th>
                            <th class="dtbodyLeft">Distributor Code & Name</th>
                            <th class="dtbodyLeft">Dealer Code & Name</th>
                            <th class="dtbodyLeft">Incl/Excl</th>
                            <th class="dtbodyLeft thElgHist">Eligible Count</th>
                            <th class="dtbodyLeft thQPSHist">QPS Qty</th>
                            <th class="dtbodyLeft">Active</th>
                            <th class="dtbodyLeft">Deleted</th>
                            <th class="dtbodyCenter">Created Date/Time</th>
                            <th class="dtbodyLeft">Created By</th>
                            <th class="dtbodyCenter">Updated Date/Time</th>
                            <th class="dtbodyLeft">Updated By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

