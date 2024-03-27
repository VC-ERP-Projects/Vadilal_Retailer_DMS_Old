<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ItemWiseCategoryMaster.aspx.cs" Inherits="Master_ItemWiseCategoryMaster" %>

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

            $('#CountRowItemCategory').val(0);
            $('#tblItemCategory').DataTable().clear().destroy();
            ShowDistOrSS();
            ClearControls();

            $('#tblItemCategory').DataTable();


            //// Start Search Region

            $(document).on('keyup', '.AutoItemCode', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoItemCode", '');
                $('#AutoItemCode' + col1).autocomplete({
                    source: function (request, response) {
                        var DivisionId = $(".ddlDivision").val();
                        $.ajax({
                            type: "POST",
                            url: 'ItemWiseCategoryMaster.aspx/GetItem',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','DivisionId':'" + DivisionId + "'}",
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
                        of: $('#AutoItemCode' + col1),
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
                        $('#AutoItemCode' + col1).val(ui.item.value + " ");
                        $('#hdnItemCode' + col1).val(ui.item.value.split("-")[0].trim());
                        $('#txtMRP' + col1).val("");
                        $('#txtCategory' + col1).val("");
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.AutoItemCode').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoItemCode", '');
                $('#AutoItemCode' + col1).val(ui.item.value);
                GetItemDetails(ui.item.value, col1);
            });

            $('.AutoItemCode').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoItemCode' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });

            $('.AutoItemCode').on('blur', function (e, ui) {

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoItemCode", '');

                if ($('#AutoItemCode' + col1).val() != "") {

                    if ($('#AutoItemCode' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Item ", 3);
                        $('#AutoItemCode' + col1).val("");
                        $('#hdnItemCode' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoItemCode' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblItemCategory > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoItemCode' + col1).val().trim(), col1, 1);
                }
            });

            ////End Item Textbox


            // start Category
            $(document).on('keyup', '.txtCategory', function () {
                var textValue = $(this).val();
                var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("txtCategory", '');
                $('#txtCategory' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'ItemWiseCategoryMaster.aspx/GetCategoryMaster',
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
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#txtCategory' + col1),
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
                        $('#txtCategory' + col1).val(ui.item.value + " ");
                        $('#hdnCategoryId' + col1).val(ui.item.value.split("#")[1].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.txtCategory').on('autocompleteselect', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("txtCategory", '');
                $('#txtCategory' + col1).val(ui.item.value);
            });

            $('.txtCategory').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#txtCategory' + col1).val() == "") {
                    ClearClaimRow(col1);
                }
            });
            $('.txtCategory').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("txtCategory", '');
                if ($('#txtCategory' + col1).val() != "") {
                    if ($('#txtCategory' + col1).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Category ", 3);
                        $('#txtCategory' + col1).val("");
                        $('#hdnCategoryId' + col1).val('0');
                        return;
                    }
                    var txt = $('#txtCategory' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblItemCategory > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                }
            });
            // End Category
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox,.txtCategory,.txtMRP').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox,.txtCategory,.txtMRP').prop('disabled', true);
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

        function CheckDuplicateData(pItemCode, row, ChkType) {

            var Item = "";
            if (pItemCode != "") {
                Item = pItemCode.split("-")[0].trim();
            }
            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            var NewFromDate = $("#tdFromDate" + row).val();
            var NewToDate = $("#tdToDate" + row).val();
            var NewSrID = $("#txtSrNo" + row).text();
            $('#tblItemCategory  > tbody > tr').each(function (row1, tr) {

                var ItemCode = $("input[name='AutoItemCode']", this).val() != "" ? $("input[name='AutoItemCode']", this).val().split("-")[0].trim() : "";

                var LineNum = $("input[name='hdnLineNum']", this).val();
                var ItemId = $("input[name='hdnItemCode']", this).val();
                var StartDate = $("input[name='tdFromDate']", this).val();
                var EndDate = $("input[name='tdToDate']", this).val();


                if (StartDate != '' && EndDate != '') {
                    var Start = StartDate.split("/");
                    var End = EndDate.split("/");
                    var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                    var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                    if (sDate != '' && eDate != '' && sDate > eDate) {
                        cnt = 1;
                        errRow = row;
                        errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                        // $("#tdToDate" + LineNum).val('');
                      
                        return false;
                    }
                }
                
                 
                    if (ItemCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == ItemCode) {
                                //cnt = 1;
                                //errRow = row;
                                //$('#AutoItemCode' + ind).val("");
                                //$('#hdnItemCode' + ind).val(0);
                                //errormsg = 'Item is already set for = ' + pItemCode + ' at row : ' + rowCnt_Claim;
                                //return false;
                                if (StartDate != '' && EndDate != '' && StartDate != undefined && EndDate != undefined) {
                                    var Start = StartDate.split("/");
                                    var End = EndDate.split("/");
                                    var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                                    var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                                    if (NewFromDate != '' && NewFromDate != undefined) {
                                        var New = NewFromDate.split("/");
                                        var nDate = new Date(New[2], parseInt(New[1]) - 1, New[0]);

                                        if ((nDate >= sDate && nDate <= eDate) || (nDate <= sDate && nDate >= eDate)) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'From Date should not be same or in between from the row : ' + rowCnt_Claim+ ' for ' + pItemCode + ' at row : ' + NewSrID;
                                            $("#tdFromDate" + row).val('');
                                            return false;
                                        }
                                    }
                                    if (NewToDate != '' && NewToDate != undefined) {
                                        var New = NewToDate.split("/");
                                        var nDate = new Date(New[2], parseInt(New[1]) - 1, New[0]);

                                        if ((nDate >= sDate && nDate <= eDate) || (nDate <= sDate && nDate >= eDate)) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'To Date should not be same or in between from the row : ' + rowCnt_Claim+ ' for ' + pItemCode + ' at row : ' + NewSrID;
                                            $("#tdToDate" + row).val('');
                                            return false;
                                        }
                                    }
                                    if (NewFromDate != '' && NewFromDate != undefined && NewToDate != '' && NewToDate != undefined) {
                                        var nfDate = new Date(NewFromDate.split("/")[2], parseInt(NewFromDate.split("/")[1]) - 1, NewFromDate.split("/")[0]);
                                        var ntDate = new Date(NewToDate.split("/")[2], parseInt(NewToDate.split("/")[1]) - 1, NewToDate.split("/")[0]);

                                        if (nfDate > ntDate) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'To Date should not be less than to From date at row : ' + NewSrID;
                                          //  $("#tdToDate" + row).val('');
                                            return false;
                                        }

                                        if ((nfDate >= sDate && ntDate <= eDate) || (ntDate >= sDate && nfDate <= eDate)) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'From/To Date should not be same or in between from the row : ' + rowCnt_Claim+ ' for ' + pItemCode + ' at row : ' + NewSrID;
                                            $("#tdToDate" + row).val('');
                                            return false;
                                        }
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
               
                //$('#AutopItemCode' + row).val('');
                if (ChkType == 1) {
                    $('#AutoItemCode' + row).val("");
                }
               else if (ChkType == 2) {
                   $("#tdFromDate" + row).val('');
               }
               else if (ChkType == 3) {
                   $("#tdToDate" + row).val('');
               }
                ClearClaimRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowItemCategory').val();
            if (ind == row) {
                AddMoreRow();
            }
        }


        function ClearClaimRow(row) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblItemCategory > tbody > tr').each(function (row1, tr) {
                var ItemName = $("input[name='AutoItemCode']", this).val();
                if (ItemName == "") {
                    // $(this).remove();
                }
                cnt++;
                rowCnt_Claim++;
            });

            if (cnt > 1) {
                var rowCnt_Claim = 1;
                $('#tblItemCategory > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var hdnOICMID = $("input[name='hdnOICMID']", this).val();
                        var Item = $("input[name='AutoItemCode']", this).val();
                        if (Item == "") {
                         //   $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblItemCategory > tbody > tr').each(function (row, tr) {
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

            $('#tblItemCategory  > tbody').empty();
            var option = $(".ddlOption").val();
            var DivisionId = $(".ddlDivision").val();
            var IsValid = true;
            $.ajax({
                url: 'ItemWiseCategoryMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: "{ 'optionId':'" + option + "','DivisionId':'" + DivisionId + "'}",
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
                            $('#tblItemCategory  > tbody > tr').each(function (row2, tr) {
                                $(this).remove();
                            });
                            var trHTML = '';
                            var row4 = 1;
                            $('#CountRowItemCategory').val(0);
                            var indE = $('#CountRowItemCategory').val();
                            $('#CountRowItemCategory').val(indE);
                            var length = 0;
                            var itm = this;
                            // var table = $('#tblItemCategory').DataTable();

                            for (var i = 0; i < items.length; i++) {
                                row4 = $('#CountRowItemCategory').val();
                                //$('#chkEditEmp' + row4).click();
                                //  $('#chkEditEmp' + row4).prop("checked", false);
                                $('table#divEmpClaimLevel tr#NoROW').remove();  // Remove NO ROW
                                /// Add Dynamic Row to the existing Table
                                var indE = $('#CountRowItemCategory').val();
                                indE = parseInt(indE) + 1;
                                $('#CountRowItemCategory').val(indE);
                                var strEmp = "";
                                strEmp = "<tr id='trItmCat" + indE + "'>"
                                    + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + indE + "'>" + indE + "</td>"
                                    + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit ' checked='false'/>"
                                    + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                                    + "<td class='dtbodyCenter'><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indE + ");' /></td>"
                                    + "<td class='tdRegion'><input type='text' id='AutoItemCode" + indE + "' name='AutoItemCode' onchange='ChangeData(this);' class='form-control search AutoItemCode ' value='" + items[i].ItemCodeName + "' disabled='false' /></td>"
                                    + "<td id='tdItemGroup" + indE + "' class='tdItemGroup'>" + items[i].ItemGroupName + "</td>"
                                    + "<td id='tdItemSubGroup" + indE + "' class='tdItemSubGroup'>" + items[i].ItemSubGroupName + "</td>"
                                    + "<td id='tdUOM" + indE + "' class='tdUOM'>" + items[i].UOM + "</td>"
                                    + "<td><input  disabled='false'  type='text' id='tdFromDate" + indE + "'name='tdFromDate' onchange='ChangeDataDateValidation(this);' class='form-control startdate search dtbodyCenter' value=" + items[i].FromDate + " onpaste='return true;'/></td>"
                                    + "<td><input   disabled='false' type='text' id='tdToDate" + indE + "'name='tdToDate' onchange='ChangeDataDateValidationToDate(this);' class='form-control enddate search dtbodyCenter' value=" + items[i].ToDate + " onpaste='return true;'/></td>"
                                    + "<td class='dtbodyRight tdMRP'><input type='text' id='txtMRP" + indE + "' name='txtMRP' onchange='ChangeData(this);' maxlength='6'  onkeypress='return isNumber(event)' class='form-control txtMRP' value='" + items[i].MRPORCate + "'  disabled='false'/></td>"
                                    + "<td class='tdCate'><input type='text' id='txtCategory" + indE + "' name='txtCategory' onchange='ChangeData(this);'    class='form-control search txtCategory' value='" + items[i].MRPORCate + "'  disabled='false'/></td>"
                                    + "<td class='dtbodyCenter'><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox' disabled='false' /></td>"
                                    //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'>" + items[i].CreatedBy + "</td>"
                                    //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'>" + items[i].CreatedDate + "</td>"
                                    + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate dtbodyCenter'>" + items[i].UpdatedDate + "</td>"
                                    + "<input type='hidden' class='hdnItemCode' id='hdnItemCode" + indE + "' name='hdnItemCode' value='" + items[i].ItemCode + "'/></td>"
                                    + "<input type='hidden' class='hdnOICMID' id='hdnOICMID" + indE + "' name='hdnOICMID' value='" + items[i].OICMID + "'/></td>"
                                    + "<input type='hidden' class='hdnCategoryId' id='hdnCategoryId" + indE + "' name='hdnCategoryId' value='" + items[i].MRPORCate + "'/></td>"
                                    + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                                    + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";
                                $('#tblItemCategory > tbody').append(strEmp);
                                //  ShowDistOrSS();
                                $('#trItmCat' + indE).find('#chkIsActive' + indE).prop("checked", items[i].Active);
                            }
                        }
                        else {
                            $('#tblItemCategory  > tbody > tr').each(function (row2, tr) {
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
            $('.divEmpClaimLevel').attr('style', 'display:none;');
            $('.divItemCategoryReport').attr('style', 'display:none;');

            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblItemCategory tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvItemCategoryHistory')) {
                $('.gvItemCategoryHistory').DataTable().destroy();
            }
            //if ($.fn.DataTable.isDataTable('.tblItemCategory')) {
            //    $('.tblItemCategory').DataTable().destroy();
            //}
            var option = $(".ddlOption").val();
            $('.gvItemCategoryHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divItemCategoryReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
                $('.divClaimReport').removeAttr('style');
                $('.divViewDetail').removeAttr('style');


                if (option == 1) {
                    $('.thCate').hide();
                    $('.tdCate').hide();
                    $('.thMRP').show();
                    $('.tdMRP').show();

                }
                else if (option == 2) {
                    $('.tdCate').show();
                    $('.thCate').show();
                    $('.tdMRP').hide();
                    $('.thMRP').hide();

                }
            }
            else {
                $('.divEmpClaimLevel').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowItemCategory').val(0);
                //  $('#tblItemCategory').DataTable().clear().destroy();
                $('#tblItemCategory').DataTable().clear().destroy();
                FillData();
                var option = $(".ddlOption").val();
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "35px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "35px", "aTargets": 2 });
                //aryJSONColTable.push({ "width": "100px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyLeft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyLeft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyLeft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyLeft", "aTargets": 6 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 7 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 8 });
               // aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 9 });
                if (option = 1) {
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 9 });
                }
                else {
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 9 });
                }
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 10 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyLeft", "aTargets": 11 });
                aryJSONColTable.push({ "width": "65px", "sClass": "dtbodyLeft", "aTargets": 12 });
                aryJSONColTable.push({ "width": "65px", "sClass": "dtbodyCenter", "aTargets": 13 });
            }

            $('#tblItemCategory').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "sExtends": "collection",
                scrollX: false,
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
                'overflow': 'hidden',
                "bLengthChange": false,
            });

            //setTimeout(function () {

            //}, 200)
        }

        function RemoveClaimLockingRow(row) {

            var DiscountExcId = $('table#tblItemCategory tr#trItmCat' + row).find(".hdnOICMID").val();
            $('table#tblItemCategory tr#trItmCat' + row).find(".IsChange").val("1");
            $('table#tblItemCategory tr#trItmCat' + row).remove();
            $('table#tblItemCategory tr#trItmCat' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblItemCategory tr#trItmCat' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }
        function AddMoreRow() {
            $('table#tblItemCategory tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var indE = $('#CountRowItemCategory').val();

            indE = parseInt(indE) + 1;
            $('#CountRowItemCategory').val(indE);

            var strEmp = "";
            strEmp = "<tr id='trItmCat" + indE + "'>"
                + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + indE + "'>" + indE + "</td>"
                + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td class='dtbodyCenter'><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + indE + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimLockingRow(" + indE + ");' /></td>"
                + "<td class='tdRegion'><input type='text' id='AutoItemCode" + indE + "' name='AutoItemCode' onchange='ChangeData(this);' class='form-control search AutoItemCode ' /></td>"
                + "<td id='tdItemGroup" + indE + "' class='tdItemGroup'></td>"
                + "<td id='tdItemSubGroup" + indE + "' class='tdItemSubGroup'></td>"
                + "<td id='tdUOM" + indE + "' class='tdUOM'></td>"
                + "<td><input  type='text' id='tdFromDate" + indE + "'name='tdFromDate' onchange='ChangeDataDateValidation(this);' class='form-control startdate search dtbodyCenter' onpaste='return true;'/></td>"
                + "<td><input  type='text' id='tdToDate" + indE + "'name='tdToDate' onchange='ChangeDataDateValidationToDate(this);' class='form-control enddate search dtbodyCenter' onpaste='return true;'   /></td>"
                + "<td class='dtbodyRight tdMRP'><input type='text' id='txtMRP" + indE + "' name='txtMRP' onchange='ChangeData(this);' maxlength='6' onkeypress='return isNumber(event)' class='form-control txtMRP'/></td>"
                + "<td class='tdCate'><input type='text' id='txtCategory" + indE + "' name='txtCategory' onchange='ChangeData(this);'   class='form-control txtCategory search'/></td>"
                + "<td class='dtbodyCenter'><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox' checked=true/></td>"
                //+ "<td id='tdCreatedByEmp" + indE + "' class='tdCreatedBy'></td>"
                //+ "<td id='tdCreatedDateEmp" + indE + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnOICMID' id='hdnOICMID" + indE + "' name='hdnOICMID'/></td>"
                + "<input type='hidden' class='hdnItemCode' id='hdnItemCode" + indE + "' name='hdnItemCode'  /></td>"
                + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnCategoryId' id='hdnCategoryId" + indE + "' name='hdnCategoryId'/></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";
            $('#tblItemCategory > tbody').append(strEmp);
            $('#tblItemCategory tbody tr:last-child td:first-child').click();

            ShowDistOrSS();
            $('.chkEdit').hide();
            $('.startdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1),
                onClose: function () {
                    this.focus()
                }
            });

            $('.enddate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1),
                onClose: function () {
                    this.focus()
                }
            });

          

            //Start Region Textbox
            $('#AutoItemCode' + indE).autocomplete({
                source: function (request, response) {
                    var DivisionId = $(".ddlDivision").val();
                    $.ajax({
                        url: 'ItemWiseCategoryMaster.aspx/GetItem',
                        type: "POST",
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','DivisionId':'" + DivisionId + "'}",
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
                    $('#hdnItemCode' + indE).val(ui.item.id);
                    $('#AutoItemCode' + indE).val(ui.item.value + " ");
                    $('#txtCategory' + indE).val("");
                    $('#txtMRP' + indE).val("");
                },
                change: function (event, ui) {
                    if (!ui.item) {
                    }
                },
                minLength: 1
            });
            $('#AutoItemCode' + indE).on('autocompleteselect', function (e, ui) {
                $('#AutoItemCode' + indE).val(ui.item.value);
                GetItemDetails(ui.item.value, indE);
            });

            $('#AutoItemCode' + indE).on('change keyup', function () {
                if ($('#AutoItemCode' + indE).val() == "") {
                    ClearClaimRow(indE);
                }
            });

            $('#AutoItemCode' + indE).on('blur', function (e, ui) {

                if ($('#AutoItemCode' + indE).val().trim() != "") {
                    if ($('#AutoItemCode' + indE).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Item", 3);
                        $('#AutoItemCode' + indE).val("");
                        $('#hdnItemCode' + indE).val('0');
                        return;
                    }
                    var txt = $('#AutoItemCode' + indE).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoItemCode' + indE).val().trim(), indE, 1);
                }
            });


            $('#txtCategory' + indE).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: 'ItemWiseCategoryMaster.aspx/GetCategoryMaster',
                        type: "POST",
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            // console.log(data);
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
                    $('#hdnCategoryId' + indE).val(ui.item.value.split("#")[1].trim());
                    $('#txtCategory' + indE).val(ui.item.value + " ");
                },
                change: function (event, ui) {
                    if (!ui.item) {
                    }
                },

                minLength: 1
            });
            $('#txtCategory' + indE).on('autocompleteselect', function (e, ui) {
                $('#txtCategory' + indE).val(ui.item.value);
            });

            $('#txtCategory' + indE).on('change keyup', function () {
                if ($('#txtCategory' + indE).val() == "") {
                    ClearClaimRow(indE);
                }
            });

            $('#txtCategory' + indE).on('blur', function (e, ui) {
                if ($('#txtCategory' + indE).val().trim() != "") {
                    if ($('#txtCategory' + indE).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Category", 3);
                        $('#txtCategory' + indE).val("");
                        $('#hdnCategoryId' + indE).val('0');
                        return;
                    }
                    var txt = $('#txtCategory' + indE).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblEmpDiscount > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                }
            });
        }
        function Cancel() {
            window.location = "../Master/ItemWiseCategoryMaster.aspx";
        }
        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowItemCategory').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
            //CheckDateValidation(row);
            CheckDuplicateData($(txt).parent().parent().find("input[name='AutoItemCode']").val(), row, 1);
        }
        function ChangeDataDateValidation(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowItemCategory').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
            //CheckDateValidation(row);
            CheckDuplicateData($(txt).parent().parent().find("input[name='AutoItemCode']").val(), row, 2);
        }
        function ChangeDataDateValidationToDate(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowItemCategory').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
            //CheckDateValidation(row);
            CheckDuplicateData($(txt).parent().parent().find("input[name='AutoItemCode']").val(), row, 3);
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
            debugger;
            var option = $(".ddlOption").val();
            $('#tblItemCategory  > tbody > tr').each(function (row, tr) {
                var Itm = $("input[name='AutoItemCode']", this).val().trim();
                if (option == 1) {
                    var MRP = $("input[name='txtMRP']", this).val();
                    if (Itm != "") {
                        if (MRP == 0 || MRP < 0 || MRP == "") {
                            $.unblockUI();
                            IsValid = false;
                            ModelMsg("Please enter MRP : " + (parseInt(row) + 1), 3);
                            return false;
                        }
                    }
                }
                else {
                    var Category = $("input[name='txtCategory']", this).val();
                    if (Itm != "") {
                        if (Category == "") {
                            $.unblockUI();
                            IsValid = false;
                            ModelMsg("Please  select Category : " + (parseInt(row) + 1), 3);
                            return false;
                        }
                    }
                }
            });
            $('#tblItemCategory  > tbody > tr').each(function (row, tr) {
                var ItemCode = "";
                ItemCode = $("input[name='AutoItemCode']", this).val().split('-')[0].trim();
                var FromDate = $("input[name='tdFromDate']", this).val();
                var ToDate = $("input[name='tdToDate']", this).val();

                if (option == 1) {

                    var IsDeleted = $('#hdnIsRowDeleted').val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    var MRP = $("input[name='txtMRP']", this).val()

                    if ((ItemCode != "") && (IsChange == "1" || IsDeleted == 1)) {
                        if (FromDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper From Date at row ' + (row + 1), 3);
                            return false;
                        }
                        if (ToDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper To Date at row ' + (row + 1), 3);
                            return false;
                        }
                        totalItemcnt = 1;
                        var OICMID = $("input[name='hdnOICMID']", this).val().trim();
                        var ItmCode = $("input[name='hdnItemCode']", this).val().trim();
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IsChange = $("input[name='IsChange']", this).val().trim();

                        var obj = {
                            OICMID: OICMID,
                            ItemCode: ItmCode,
                            FromDate: FromDate,
                            ToDate: ToDate,
                            Active: IsActive,
                            MRPOrCatId: MRP,
                            IsChange: IsChange
                        };
                        TableData_Claim.push(obj);
                        rowCnt_Claim++;
                    }
                }
                if (option == 2) {

                    var IsDeleted = $('#hdnIsRowDeleted').val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();

                    if ((ItemCode != "") && (IsChange == "1" || IsDeleted == 1)) {
                        if (FromDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper From Date at row ' + (row + 1), 3);
                            return false;
                        }
                        if (ToDate == '') {
                            totalItemcnt = 0;
                            $.unblockUI();
                            ModelMsg('Please select proper To Date at row ' + (row + 1), 3);
                            return false;
                        }
                        totalItemcnt = 1;
                        var OICMID = $("input[name='hdnOICMID']", this).val().trim();
                        var hdnCateId = $("input[name='hdnCategoryId']", this).val().trim();
                        var ItmCode = $("input[name='hdnItemCode']", this).val().trim();
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IsChange = $("input[name='IsChange']", this).val().trim();
                        var obj = {
                            OICMID: OICMID,
                            ItemCode: ItmCode,
                            FromDate: FromDate,
                            ToDate: ToDate,
                            Active: IsActive,
                            MRPOrCatId: hdnCateId,
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
            var DivisionId = $(".ddlDivision").val();
            if (IsValid) {
                var sv = $.ajax({
                    url: 'ItemWiseCategoryMaster.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputUnitMapping: UserUnitMappingData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val(), OptionId: option, DivisionId: DivisionId }),
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
                $('.tdMRP').show();
                $('.thMRP').show();
                ClearClaimRow();
                $('.thCate').hide();
                $('.tdCate').hide();
                $('.divFileUpload').show();
            }
            else if (option == 2) {
                $('.tdCate').hide();
                $('.thCate').hide();
                $('.tdMRP').show();
                $('.thMRP').show();
                ClearClaimRow();
                $('.divFileUpload').hide();
            }
            else {
            }
            ClearControls();
            $('#hdnDeleteIDs').val('');
            $('#hdnIsRowDeleted').val("0");
        }
        function ShowDistOrSS() {

            var option = $(".ddlOption").val();

            if (option == 1) {
                $('.thMRP').show();
                $('.tdCate').hide();
                $('.tdMRP').show();
                $('.thCate').hide();
                ClearClaimRow();
            }
            else if (option == 2) {
                $('.tdCate').show();
                $('.thCate').show();
                ClearClaimRow();
                $('.tdMRP').hide();
                $('.thMRP').hide();
            }
        }
        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();
                var option = $(".ddlOption").val();
                var DivisionId = $(".ddlDivision").val();
                $('.gvItemCategoryHistory tbody').empty();
                $.ajax({
                    url: 'ItemWiseCategoryMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','optionId': '" + option + "','DivisionId': '" + DivisionId + "'}",
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
                                    + "<td class='tdUser'>" + ReportData[i].ItemCodeName + "</td>"
                                    + "<td class='tdUser'>" + ReportData[i].ItemGroupName + "</td>"
                                    + "<td class='tdDist'>" + ReportData[i].ItemSubGroupName + "</td>"
                                    + "<td class='tdss'>" + ReportData[i].UOM + "</td>"
                                    + "<td>" + ReportData[i].FromDate + "</td>"
                                    + "<td>" + ReportData[i].ToDate + "</td>"
                                    + "<td class='tdMRP'>" + ReportData[i].MRPORCate + "</td>"
                                    + "<td class='tdCate'>" + ReportData[i].MRPORCate + "</td>"
                                    + "<td>" + ReportData[i].IsActive + "</td>"
                                    + "<td>" + ReportData[i].IsDeleted + "</td>"
                                    + "<td class='tdUpdateBy'>" + ReportData[i].UpdatedBy + "</td>"
                                    + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"

                                k = k + 1;
                                $('.gvItemCategoryHistory > tbody').append(str);
                            }
                            if (option == 1) {
                                $('.tdMRP').show();
                                $('.thMRP').show();
                                $('.thCate').hide();
                                $('.tdCate').hide();
                            }
                            else if (option == 2) {
                                $('.tdCate').show();
                                $('.thCate').show();
                                $('.tdMRP').hide();
                                $('.thMRP').hide();
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvItemCategoryHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });
                    var option = $(".ddlOption").val();
                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "7px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "180px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "100px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "100px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyLeft", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 7 });
                    if (option == 1) {
                        aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyRight", "aTargets": 8 });
                    }
                    else {
                        aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyLeft", "aTargets": 8 });
                    }
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyCenter", "aTargets": 12 });

                    var titleName = option == 1 ? "Itemwise MRP Master" : $("#lnkTitle").text();

                    $('.gvItemCategoryHistory').DataTable({
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
                                var data = titleName + '\n';
                                data += 'Division,' + $('.ddlDivision option:selected').text() + '\n';
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
                           
                                sheet = ExportXLS(xlsx, 7);
                                //var DivisionId = $(".ddlDivision").val();
                                var r0 = Addrow(1, [{ key: 'A', value: titleName }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivision option:selected').text() }]);
                                var r6 = Addrow(3, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r5 = Addrow(6, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r6 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                                    { text: titleName + '\n' },
                                                    { text: 'Division : ' + $('.ddlDivision option:selected').text() + "\n" },
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
                                    doc.content[0].table.body[i][4].alignment = 'left';
                                    doc.content[0].table.body[i][5].alignment = 'center';
                                    doc.content[0].table.body[i][6].alignment = 'center';
                                    if (option == 1) {
                                        doc.content[0].table.body[i][7].alignment = 'right';
                                    }
                                    else {
                                        doc.content[0].table.body[i][7].alignment = 'left';
                                    }
                                    doc.content[0].table.body[i][8].alignment = 'center';
                                    doc.content[0].table.body[i][9].alignment = 'center';
                                    doc.content[0].table.body[i][10].alignment = 'left';
                                    doc.content[0].table.body[i][11].alignment = 'center';

                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'left';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'center';
                                doc.content[0].table.body[0][6].alignment = 'center';
                                if (option == 1) {
                                    doc.content[0].table.body[0][7].alignment = 'right';
                                }
                                else {
                                    doc.content[0].table.body[0][7].alignment = 'left';
                                }
                                doc.content[0].table.body[0][8].alignment = 'center';
                                doc.content[0].table.body[0][9].alignment = 'center';
                                doc.content[0].table.body[0][10].alignment = 'left';
                                doc.content[0].table.body[0][11].alignment = 'center';

                            }
                        }]
                    });
                }
            }
        }
        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            if (charCode > 31 && charCode != 46 && (charCode < 48 || charCode > 57) || charCode == 190) {
                return false;
            }

            return true;
        }
        function GetItemDetails(ItemCode, row) {

            var ItmCode = ItemCode.split("-")[0].trim();
            console.log(ItmCode);
            $.ajax({
                url: 'ItemWiseCategoryMaster.aspx/GetItemDetails',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: "{ 'ItemCode': '" + ItmCode + "'}",
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
                        $('#tdItemGroup' + row).text(units[0].ItemGroupName);
                        $('#tdItemSubGroup' + row).text(units[0].ItemSubGroupName);
                        $('#tdUOM' + row).text(units[0].UnitName);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        function CheckDateValidation(row) {
            var rowCnt_Claim= 1;
            var cnt = 0;
            var errRow = 0;

            var NewFromDate = $("#tdFromDate" + row).val();
            var NewToDate = $("#tdToDate" + row).val();
            $('#tblItemCategory  > tbody > tr').each(function (row1, tr) {
                var LineNum = $("input[name='hdnLineNum']", this).val();
                var StartDate = $("input[name='tdFromDate']", this).val();
                var EndDate = $("input[name='tdToDate']", this).val();
                if (StartDate != '' && EndDate != '') {
                    var Start = StartDate.split("/");
                    var End = EndDate.split("/");
                    var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                    var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                    if (sDate != '' && eDate != '' && sDate > eDate) {
                        cnt = 1;
                        errRow = row;
                        errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                        //$("#tdToDate" + LineNum).val('');
                        return false;
                    }
                }
            });
            if (cnt == 1) {
                ClearClaimRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }
        }
        function downloadMapping() {
            window.open("../Document/CSV Formats/UpdateItemMRP.csv");
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

        table.dataTable thead th, table.dataTable thead td {
            padding: 10px 10px;
            border-bottom: 1px solid #111;
        }

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
                overflow-x :hidden !important;
                overflow-y :auto !important;
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

        table.tblItemCategory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100vw !important;
            margin: 0;
            table-layout: auto;
        }

        table#tblItemCategory {
            width: 100vw;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblItemCategory tbody {
                width: 100vw;
                height: 30%;
            }

                table#tblItemCategory tbody tr {
                    position: relative;
                }

            table#tblItemCategory thead tr {
                position: relative;
            }

            table#tblItemCategory tfoot tr {
                position: relative;
                width: 100vw;
            }

            table#tblItemCategory tbody tr td {
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

        table#tblItemCategory.dataTable tbody th {
            padding-left: 6px !important;
        }

        table#tblItemCategory.dataTable tbody th {
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

        #tblItemCategory {
            margin-top: 0px !important;
        }


        .txtMRP {
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
            overflow-y: hidden !important;
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
    <div class="panel panel-default">
        <div class="panel-body" style="height: 560px !important;">
            <div class="row">
                <div class="col-lg-12">
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                            <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="1" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID" onchange="ShowDistOrSSOnChange();">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Option</label>
                            <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="2" onchange="ShowDistOrSSOnChange();">
                                <asp:ListItem Value="1" Selected="True">MRP</asp:ListItem>
                                <asp:ListItem Value="2">Category</asp:ListItem>
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
            </div>
              <div class="row divFileUpload">
                    <div class="col-lg-12">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload File" ID="Label3" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flpLineItemExcInc" TabIndex="1" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnUploadItemMRP" runat="server" TabIndex="2" Text="Upload File" OnClick="btnUploadItemMRP_Click" CssClass="btn btn-primary" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Button ID="btnDownloadItemMRP" runat="server" TabIndex="3" Text="Download Format" CssClass="btn btn-primary" OnClientClick="downloadMapping(); return false;" />
                    </div>
                </div>
            </div>
                  </div>
            <div class="row _masterForm">
                <div class="col-lg-12">
                    <input type="hidden" id="CountRowItemCategory" />
                    <div id="divEmpClaimLevel" class="divEmpClaimLevel" runat="server" style="max-height: 50vh; position: absolute;">
                        <table id="tblItemCategory" class="table table-bordered nowrap" border="1" tabindex="8" style="border-collapse: collapse; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="width: 3% !important; text-align: center;">Sr</th>
                                    <th style="text-align: center;">Edit</th>
                                    <th style="text-align: center;">Delete</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Item Code & Name</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Item Group</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Item Sub-Group</th>
                                    <th style="width: 20%; padding-left: 10px !important;">UOM</th>
                                    <th style="width: 20%; padding-left: 10px !important;">From Date</th>
                                    <th style="width: 20%; padding-left: 10px !important;">To Date</th>
                                    <th style="width: 6%; padding-left: 10px !important;" class="thMRP">MRP</th>
                                    <th style="width: 6%; padding-left: 10px !important;" class="thCate">Category</th>
                                    <th style="width: 3% !important; text-align: center; padding-left: 3px !important;">Active</th>
                                    <th style="width: 7%; padding-left: 5px !important;">Updated By</th>
                                    <th style="width: 7%; text-align: center;">Update Date / Time</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div id="divItemCategoryReport" class="divItemCategoryReport" style="max-height: 50vh; overflow-y: auto;">
                        <table id="gvItemCategoryHistory" class="gvItemCategoryHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="text-align: center; width: 2%;">Sr</th>
                                    <th style="width: 10%">Item Code & Name</th>
                                    <th style="width: 10%">Item Group</th>
                                    <th style="width: 10%">Item Sub-Group</th>
                                    <th style="width: 10%">UOM</th>
                                    <th style="width: 10%">From Date</th>
                                    <th style="width: 10%">To Date</th>
                                    <th style="width: 3%;" class="thMRP">MRP</th>
                                    <th style="width: 3%;" class="thCate">Category</th>
                                    <th style="width: 3%;">Active</th>
                                    <th style="width: 3%;">Deleted</th>
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
             <div class="col-lg-12">
                <asp:GridView ID="gvProductMappingMissData" Width="100%" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField DataField="ItemCode" HeaderText="Item Code" ItemStyle-Width="5%" HeaderStyle-Width="7%" HeaderStyle-HorizontalAlign="Left" />
                        <asp:BoundField DataField="FromDate" HeaderText="From Date" ItemStyle-Width="10%" HeaderStyle-Width="7%"  HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="ToDate" HeaderText="To Date" ItemStyle-Width="10%" HeaderStyle-Width="7%"   HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center"  />
                        <asp:BoundField DataField="MRP" HeaderText="MRP" ItemStyle-Width="10%" HeaderStyle-Width="7%"   HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="ErrorMsg" HeaderText="Error Message" ItemStyle-Width="70%" HeaderStyle-Width="70%"  HeaderStyle-HorizontalAlign="Left" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

