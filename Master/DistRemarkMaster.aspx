<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DistRemarkMaster.aspx.cs" Inherits="Master_DistRemarkMaster" %>

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
        // var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var IpAddress;
        const JsonEmployee = [];
        const JsonDist = [];
        const JsonSS = [];
        $(document).ready(function () {

            $('#CountRowUserUnit').val(0);
            $('#tblEmpClaimLevel').DataTable().clear().destroy();

            ClearControls();

            $('#tblEmpClaimLevel').DataTable();



            //// Start Distributor
            //$(document).on('keyup', '.AutoDist', function () {
            //    var textValue = $(this).val();
            //    //var currentRow = $(this).closest("tr");
            //    //var col1 = currentRow.find("td:eq(0)").text();
            //    var txtId = $(this).attr("id");
            //    var col1 = txtId.replace("AutoDist", '');

            //    $('#AutoDist' + col1).autocomplete({
            //        source: function (request, response) {
            //            //var EmpId = $("#AutoEmpName" + col1).val() != "" && $("#AutoEmpName" + col1).val() != undefined ? $("#AutoEmpName" + col1).val().split("#")[2].trim() : "0";
            //            //var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
            //            var EmpId = 0;
            //            var RegionId = 0;
            //            $.ajax({
            //                type: "POST",
            //                url: 'DistRemarkMaster.aspx/SearchDistributor',
            //                dataType: "json",
            //                data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "'}",
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
            //        position: {
            //            my: 'left top',
            //            at: 'right top',
            //            collision: 'flip flip',
            //            of: $('#AutoDist' + col1),
            //            using: function (obj, info) {
            //                if (info.vertical != "top") {
            //                    $(this).addClass("flipped");
            //                } else {
            //                    $(this).removeClass("flipped");
            //                }
            //                if (info.horizontal != "left") {
            //                    $(this).addClass("flipped");
            //                } else {
            //                    $(this).removeClass("flipped");
            //                }
            //                $(this).css({
            //                    left: obj.left + 'px',
            //                    top: obj.top + 'px'
            //                });
            //            }
            //        },
            //        select: function (event, ui) {

            //            $('#AutoDist' + col1).val(ui.item.value + " ");
            //            $('#hdnDistId' + col1).val(ui.item.value.split("#")[2].trim());
            //        },
            //        change: function (event, ui) {
            //            if (!ui.item) {

            //            }
            //        },
            //        minLength: 1
            //    });
            //});

            //$('.AutoDist').on('autocompleteselect', function (e, ui) {
            //    var txtId = $(this).attr("id");
            //    var col1 = txtId.replace("AutoDist", '');
            //    $('#AutoDist' + col1).val(ui.item.value);

            //});
            //$('.AutoDist').on('change keyup', function () {
            //    var txtId = $(this).attr("id");
            //    var col1 = txtId.replace("AutoDist", '');
            //    if ($('#AutoDist' + col1).val() == "") {
            //        ClearClaimRow(col1);
            //    }
            //});

            //$('.AutoDist').on('blur', function (e, ui) {
            //    var txtId = $(this).attr("id");
            //    var col1 = txtId.replace("AutoDist", '');
            //    if ($('#AutoDist' + col1).val().trim() != "") {
            //        if ($('#AutoDist' + col1).val().indexOf('#') == -1) {
            //            ModelMsg("Select Proper Distributor", 3);
            //            $('#AutoDist' + col1).val("");
            //            $('#hdnDistId' + col1).val('0');
            //            return;
            //        }
            //        var txt = $('#AutoDist' + col1).val().trim();
            //        if (txt == "undefined" || txt == "") {
            //            return false;
            //        }
            //        var lineNum = 1;
            //        $('#tblEmpClaimLevel > tbody > tr').each(function (row, tr) {
            //            $(".txtSrNo", this).text(lineNum);
            //            lineNum++;
            //        });
            //        CheckDuplicateData($('#AutoRegion' + col1).val().trim(), $('#AutoEmpName' + col1).val().trim(), $('#AutoDist' + col1).val().trim(), $('#AutoSS' + col1).val().trim(), col1, 3);

            //    }
            //});
            ////End Distributor


            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox,.txtLevel').prop('disabled', false);
                    $(this).val('Update');
                     
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox,.txtLevel').prop('disabled', true);
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

        function CheckDuplicateData(Remarks1,Remarks2,row) {

            debugger;
            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            var NewFromDate = $("#tdFromDate" + row).val();
            var NewToDate = $("#tdToDate" + row).val();
            var NewRemark1 = $("#txtRemarks1" + row).val();
            var NewRemark2 = $("#txtRemarks2" + row).val();
            $('#tblEmpClaimLevel  > tbody > tr').each(function (row1, tr) {

                debugger;
                var Remarks1 = $("input[name='txtRemarks1']", this).val();
                var Remarks2 = $("input[name='txtRemarks2']", this).val();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                var DistId = $("input[name='hdnDistId']", this).val();
                var StartDate = $("input[name='tdFromDate']", this).val();
                var EndDate = $("input[name='tdToDate']", this).val();
                if (Remarks1 != "" || Remarks2 !="") {
                    if (StartDate != '' && EndDate != '') {
                        var Start = StartDate.split("/");
                        var End = EndDate.split("/");
                        var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                        var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);
                        if (sDate != '' && eDate != '' && sDate > eDate) {
                            cnt = 1;
                            errRow = row;
                            errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                            $("#tdToDate" + LineNum).val('');
                            return false;
                        }
                        if ((NewRemark1 != Remarks1 || Remarks2 != NewRemark2)) {
                            if (StartDate != '' && EndDate != '' && StartDate != undefined && EndDate != undefined) {
                                //var Start = StartDate.split("/");
                                //var End = EndDate.split("/");
                                //var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                                //var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                                if (NewFromDate != '' && NewFromDate != undefined) {
                                    var New = NewFromDate.split("/");
                                    var nDate = new Date(New[2], parseInt(New[1]) - 1, New[0]);

                                    if ((nDate >= sDate && nDate <= eDate) || (nDate <= sDate && nDate >= eDate)) {
                                        cnt = 1;
                                        errRow = row;
                                        errormsg = 'From Date should not be same or in between from the row : ' + LineNum;
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
                                        errormsg = 'To Date should not be same or in between from the row : ' + LineNum;
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
                                        errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                                        $("#tdToDate" + row).val('');
                                        return false;
                                    }

                                    if ((nfDate >= sDate && ntDate <= eDate) || (ntDate >= sDate && nfDate <= eDate)) {
                                        cnt = 1;
                                        errRow = row;
                                        errormsg = 'From/To Date should not be same or in between from the row : ' + LineNum;
                                        $("#tdToDate" + row).val('');
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
                rowCnt_Claim++;
                //}
            });
            if (cnt == 1) {
               // $('#AutoDist' + row).val('');
                ClearClaimRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowUserUnit').val();
            if (ind == row) {
                AddMoreRow();
            }
        }


        function ClearClaimRow(row) {
            var rowCnt_Claim = 1;
            var cnt = 0;
            $('#tblEmpClaimLevel > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var Region = $("input[name='AutoEmpName']", this).val();
                var EmpCode = $("input[name='AutoEmpName']", this).val();
                var Distributor = $("input[name='AutoEmpName']", this).val();
                var SS = $("input[name='AutoEmpName']", this).val();
                if (EmpCode == "") {
                    // $(this).remove();
                }
                cnt++;
                rowCnt_Claim++;
            });

            if (cnt > 1) {
                var rowCnt_Claim = 1;
                $('#tblEmpClaimLevel > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var hdnOCLEID = $("input[name='hdnOCLEID']", this).val();
                        var DistCode = $("input[name='AutoDist']", this).val();
                        //if (  DistCode == "" ) {
                        //    $(this).remove();
                        //}
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblEmpClaimLevel > tbody > tr').each(function (row, tr) {
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

            $('#tblEmpClaimLevel  > tbody').empty();

            var IsValid = true;
            $.ajax({
                url: 'DistRemarkMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({}),
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
                            $('#tblEmpClaimLevel  > tbody > tr').each(function (row2, tr) {
                                $(this).remove();
                            });
                            var trHTML = '';
                            var row4 = 1;
                            $('#CountRowUserUnit').val(0);
                            var indE = $('#CountRowUserUnit').val();
                            $('#CountRowUserUnit').val(indE);
                            var length = 0;
                            var itm = this;
                            // var table = $('#tblEmpClaimLevel').DataTable();

                            for (var i = 0; i < items.length; i++) {
                                row4 = $('#CountRowUserUnit').val();
                                //$('#chkEditEmp' + row4).click();
                                //  $('#chkEditEmp' + row4).prop("checked", false);
                                $('table#divEmpClaimLevel tr#NoROW').remove();  // Remove NO ROW
                                /// Add Dynamic Row to the existing Table
                                var indE = $('#CountRowUserUnit').val();
                                indE = parseInt(indE) + 1;
                                $('#CountRowUserUnit').val(indE);
                                var strEmp = "";
                                strEmp = "<tr id='trUserMap" + indE + "'>"
                                    + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + indE + "'>" + indE + "</td>"
                                    + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit ' checked='false'/>"
                                    + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                                    + "<td class='tdRegion'><input type='text' id='txtRemarks1" + indE + "' name='txtRemarks1' onchange='ChangeData(this);' class='form-control search1 txtRemarks1 ' value='" + items[i].Remarks1 + "' disabled='false'  MaxLength='150' /></td>"
                                    + "<td class='tdUser'><input type='text' id='txtRemarks2" + indE + "' name='txtRemarks2' onchange='ChangeData(this);' class='form-control search1 txtRemarks2' value='" + items[i].Remarks2 + "' disabled='false'  MaxLength='150'  /></td>"
                                    /*+ "<td class='tdDist'><input type='text' id='AutoDist" + indE + "' name='AutoDist' onchange='ChangeData(this);' class='form-control search AutoDist' value='" + items[i].DistName + "' disabled='false' /></td>"*/
                                    /*+ "<td class='dtbodyCenter'><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox' disabled='false' /></td>"*/
                                   /* + "<td class='dtbodyCenter'><input type='checkbox' id='chkIsHeirchy" + indE + "' name='chkIsHeirchy' onchange='ChangeData(this);'  class='checkbox' disabled='false' /></td>"*/
                                    + "<td><input readonly type='text' id='tdFromDate" + indE + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search1  dtbodyCenter' value=" + items[i].FromDate + " onpaste='return false;' disabled='false'/></td>"
                                    + "<td><input readonly type='text' id='tdToDate" + indE + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' value=" + items[i].ToDate + " onpaste='return false;'/></td>"
                                    + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate dtbodyCenter'>" + items[i].UpdatedDate + "</td>"
                                    + "<input type='hidden' class='hdnDistId' id='hdnDistId" + indE + "' name='hdnDistId' value='" + items[i].DealerId + "'/></td>"
                                    + "<input type='hidden' class='hdnOCLEID' id='hdnOCLEID" + indE + "' name='hdnOCLEID' value='" + items[i].RemarksId + "' /></td>"
                                    + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                                    + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";
                                $('#tblEmpClaimLevel > tbody').append(strEmp);
                                //  ShowDistOrSS();
                                $('#trUserMap' + indE).find('#chkIsHeirchy' + indE).prop("checked", items[i].Include);
                                $('#trUserMap' + indE).find('#chkIsActive' + indE).prop("checked", items[i].Active);


                                $('.startdate').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });

                                $('.enddate').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });

                                $('.search,.checkbox,.search1').prop('disabled', true);
                            }
                        }
                        else {
                            $('#tblEmpClaimLevel  > tbody > tr').each(function (row2, tr) {
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
            $('.divEmpClaimLevelReport').attr('style', 'display:none;');

            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblEmpClaimLevel tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvEmpClaimLevelHistory')) {
                $('.gvEmpClaimLevelHistory').DataTable().destroy();
            }

            $('.gvEmpClaimLevelHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divEmpClaimLevelReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
                $('.divClaimReport').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divEmpClaimLevel').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowUserUnit').val(0);
                //  $('#tblEmpClaimLevel').DataTable().clear().destroy();
                $('#tblEmpClaimLevel').DataTable().clear().destroy();
                FillData();

                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "35px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "300px", "sClass": "dtbodyLeft", "aTargets": 2 });
                //aryJSONColTable.push({ "width": "100px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "300px", "sClass": "dtbodyLeft", "aTargets": 3 });
              /*  aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyLeft", "aTargets": 4 });*/
               /* aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyLeft", "aTargets": 4 });*/
                /*aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyLeft", "aTargets": 4 });*/
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 4 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 5 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyLeft", "aTargets":  6 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyCenter", "aTargets": 7 });

            }

            $('#tblEmpClaimLevel').DataTable({
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

        function RemoveClaimLockingRow(row) {

            var DiscountExcId = $('table#tblEmpClaimLevel tr#trUserMap' + row).find(".hdnOCLEID").val();
            $('table#tblEmpClaimLevel tr#trUserMap' + row).find(".IsChange").val("1");
            $('table#tblEmpClaimLevel tr#trUserMap' + row).remove();
            $('table#tblEmpClaimLevel tr#trUserMap' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblEmpClaimLevel tr#trUserMap' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }
        function AddMoreRow() {
            $('table#tblEmpClaimLevel tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var indE = $('#CountRowUserUnit').val();

            indE = parseInt(indE) + 1;
            $('#CountRowUserUnit').val(indE);

            var strEmp = "";
            strEmp = "<tr id='trUserMap" + indE + "'>"
                + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + indE + "'>" + indE + "</td>"
                + "<td class='dtbodyCenter'><input type='checkbox' id='chkEdit" + indE + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + indE + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td class='txtRemarks1'><input type='text' id='txtRemarks1" + indE + "' name='txtRemarks1'   class='form-control search txtRemarks1' MaxLength='150' /></td>"
                + "<td class='txtRemarks2'><input type='text' id='txtRemarks2" + indE + "' name='txtRemarks2'  class='form-control search txtRemarks2'  MaxLength='150'/></td>"
                /*+ "<td class='tdDist'><input type='text' id='AutoDist" + indE + "' name='AutoDist' onchange='ChangeData(this);' class='form-control search AutoDist' /></td>"*/
                /*+ "<td class='dtbodyCenter'><input type='checkbox' id='chkIsActive" + indE + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"*/
                /*+ "<td class='dtbodyCenter'><input type='checkbox' id='chkIsHeirchy" + indE + "' name='chkIsHeirchy' onchange='ChangeData(this);'  class='checkbox'/></td>"*/
                + "<td><input readonly type='text' id='tdFromDate" + indE + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search dtbodyCenter' onpaste='return false;'/></td>"
                + "<td><input readonly type='text' id='tdToDate" + indE + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' onpaste='return false;'/></td>"

                + "<td id='tdUpdateByEmp" + indE + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDateEmp" + indE + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnOCLEID' id='hdnOCLEID" + indE + "' name='hdnOCLEID'/></td>"
                + "<input type='hidden' class='hdnDistId' id='hdnDistId" + indE + "' name='hdnDistId'  /></td>"
                + "<input type='hidden' class='IsChange' id='IsChange" + indE + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + indE + "' name='hdnLineNum' value='" + indE + "' /></tr>";

            $('#tblEmpClaimLevel > tbody').append(strEmp);
            $('#tblEmpClaimLevel tbody tr:last-child td:first-child').click();

            $('.chkEdit').hide();
            //  $('.chkEdit').prop("checked", true);
            var table = document.getElementById("tblEmpClaimLevel");


            $('.startdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });

            $('.enddate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });



            ////Start Distributor Textbox           
            //$('#AutoDist' + indE).keyup(function () {
            //    var textValue = $(this).val();
            //    var currentRow = $(this).closest("tr");
            //    var col1 = currentRow.find("td:eq(0)").text();
            //    $('#AutoDist' + col1).autocomplete({
            //        source: function (request, response) {
            //            //var EmpId = $("#AutoEmpName" + col1).val() != "" && $("#AutoEmpName" + col1).val() != undefined ? $("#AutoEmpName" + col1).val().split("#")[2].trim() : "0";
            //            //var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
            //            var EmpId = 0;
            //            var RegionId = 0;
            //            $.ajax({
            //                type: "POST",
            //                url: 'DistRemarkMaster.aspx/SearchDistributor',
            //                dataType: "json",
            //                data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "'}",
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
            //            $('#AutoDist' + col1).val(ui.item.value + " ");
            //            $('#hdnDistId' + col1).val(ui.item.value.split("#")[2].trim());
            //        },
            //        change: function (event, ui) {
            //            if (!ui.item) {

            //            }
            //        },
            //        minLength: 1
            //    });
            //});

            //$('#AutoDist' + indE).autocomplete({
            //    source: JsonDist,
            //    position: { collision: "flip" },
            //    select: function (event, ui) {
            //        $('#hdnDistId' + indE).val(ui.item.value.split('#')[2].trim());
            //        $('#AutoDist' + indE).val(ui.item.value + " ");
            //        //   $('#hdnDistId' + indE).val(ui.item.value.split("#")[2].trim());
            //    },
            //    change: function (event, ui) {
            //        if (!ui.item) {
            //        }
            //    },
            //    minLength: 1
            //});

            //$('#AutoDist' + indE).on('autocompleteselect', function (e, ui) {

            //    $('#AutoDist' + indE).val(ui.item.value);

            //});

            //$('#AutoDist' + indE).on('change keyup', function () {
            //    if ($('#AutoDist' + indE).val() == "") {

            //        ClearClaimRow(indE);
            //        // $('#hdnDistId' + indE).val(0);

            //    }
            //});

            //$('#AutoDist' + indE).on('blur', function (e, ui) {
            //    if ($('#AutoDist' + indE).val().trim() != "") {

            //        if ($('#AutoDist' + indE).val().indexOf('#') == -1) {
            //            ModelMsg("Select Proper Distributor", 3);
            //            $('#AutoDist' + indE).val("");
            //            $('#hdnDistId' + indE).val('0');
            //            return;
            //        }
            //        var txt = $('#AutoDist' + indE).val().trim();

            //        if (txt == "undefined" || txt == "") {
            //            //ModelMsg("Enter Item Code Or Name", 3);
            //            return false;
            //        }
            //        var lineNum = 1;
            //        $('#tblEmpClaimLevel > tbody > tr').each(function (row, tr) {
            //            $(".txtSrNo", this).text(lineNum);
            //            lineNum++;
            //        });
            //        CheckDuplicateData($('#AutoRegion' + indE).val().trim(), $('#AutoEmpName' + indE).val().trim(), $('#AutoDist' + indE).val().trim(), $('#AutoSS' + indE).val().trim(), indE, 3);
            //    }
            //});
            ////End Distributor textbox

        }
        function Cancel() {
            window.location = "../Master/DistRemarkMaster.aspx";
        }
        function ChangeData(txt) {
            //$(txt).parent().parent().find("input[name='IsChange']").val("1");
            //var ind = $('#CountRowUserUnit').val();
            //var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            //if (ind == row) {
            //    AddMoreRow();
            //}
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            CheckDuplicateData($(txt).parent().parent().find("input[name='txtRemarks1']").val(), $(txt).parent().parent().find("input[name='txtRemarks2']").val(),Number($(txt).parent().parent().find("input[name='hdnLineNum']").val()));

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


            $('#tblEmpClaimLevel  > tbody > tr').each(function (row, tr) {

                var FromDate = $("input[name='tdFromDate']", this).val();
                var ToDate = $("input[name='tdToDate']", this).val();
                var IsHeirachy = $("input[name='chkIsHeirchy']", this).is(':checked');
              //  var Dist = $("input[name='AutoDist']", this).val().split('#').pop().trim();
                var IsDeleted = $('#hdnIsRowDeleted').val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                var Remarks1 = $("input[name='txtRemarks1']", this).val().trim();
                var Remarks2 = $("input[name='txtRemarks2']", this).val().trim();
                if (((Remarks1 != "" || Remarks2 != "") && FromDate != "" && ToDate != "") && (IsChange == "1" || IsDeleted == 1)) {
                    totalItemcnt = 1;
                    var OCLEID = $("input[name='hdnOCLEID']", this).val().trim();

                    var DistId = $("input[name='hdnDistId']", this).val().trim();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');

                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    if (FromDate == "") {
                        ModelMsg('Please select proper FromDate at row : ' + (rowCnt_FSSI + 1), 3);
                        IsValid = false;
                    }

                    if (ToDate == "") {
                        ModelMsg('Please select proper ToDate at row : ' + (rowCnt_FSSI + 1), 3);
                        IsValid = false;
                    }
                    if (Remarks1 == "") {
                        if (Remarks2 != "") {
                            Remarks1 = Remarks2;
                            Remarks2 = "";
                        }
                    }
                        
                    var obj = {
                        OCLEID: OCLEID,
                        Remarks1: Remarks1,
                        Remarks2: Remarks2,
                        DistId: DistId,
                        Active: IsActive,
                        IsHeirachy: IsHeirachy,
                        FromDate: FromDate,
                        ToDate: ToDate,
                        IsChange: IsChange
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
            var UserUnitMappingData = JSON.stringify(TableData_Claim);
            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'DistRemarkMaster.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputUnitMapping: UserUnitMappingData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val() }),
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
                $('.gvEmpClaimLevelHistory tbody').empty();
                $.ajax({
                    url: 'DistRemarkMaster.aspx/LoadReport',
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
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";
                            var k = 1;
                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + k + "</td>"
                                    + "<td class='tdRegion'>" + ReportData[i].Remarks1 + "</td>"
                                    + "<td class='tdRemarks'>" + ReportData[i].Remarks2 + "</td>"
                                    + "<td class='tdBeatEmp'>" + ReportData[i].CustomerName + "</td>"
                                    + "<td>" + ReportData[i].IsActive + "</td>"
                                    + "<td>" + ReportData[i].IncludeIs + "</td>"
                                    + "<td>" + ReportData[i].FromDate + "</td>"
                                    + "<td>" + ReportData[i].ToDate + "</td>"
                                    + "<td>" + ReportData[i].IsDeleted + "</td>"
                                    + "<td class='tdUpdateBy'>" + ReportData[i].UpdatedBy + "</td>"
                                    + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"
                                k = k + 1;
                                $('.gvEmpClaimLevelHistory > tbody').append(str);
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvEmpClaimLevelHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });
                    var option = $(".ddlOption").val();
                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "7px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyLeft", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyLeft", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyLeft", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 10 });

                    $('.gvEmpClaimLevelHistory').DataTable({
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
                                    doc.content[0].table.body[i][4].alignment = 'center';
                                    doc.content[0].table.body[i][5].alignment = 'right';
                                    doc.content[0].table.body[i][6].alignment = 'center';
                                    doc.content[0].table.body[i][7].alignment = 'center';
                                    doc.content[0].table.body[i][8].alignment = 'left';
                                    doc.content[0].table.body[i][9].alignment = 'center';

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
                                doc.content[0].table.body[0][9].alignment = 'center';
                                // doc.content[0].table.body[0][8].alignment = 'left';


                            }
                        }]
                    });
                }
            }
        }
        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;

            if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode != 45) {
                return false;
            }

            return true;
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

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 2px 5px !important;
        }

        table.tblUserUnitMap.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100vw !important;
            margin: 0;
            table-layout: auto;
        }

        table#tblEmpClaimLevel {
            width: 100vw;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblEmpClaimLevel tbody {
                width: 100vw;
                height: 30%;
            }

                table#tblEmpClaimLevel tbody tr {
                    position: relative;
                }

            table#tblEmpClaimLevel thead tr {
                position: relative;
            }

            table#tblEmpClaimLevel tfoot tr {
                position: relative;
                width: 100vw;
            }

            table#tblEmpClaimLevel tbody tr td {
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

        .search,.search1 {
            font-size: 10px !important;
            height: 22px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }


        .ui-autocomplete {
            position: absolute;
        }

        table#tblEmpClaimLevel.dataTable tbody th {
            padding-left: 6px !important;
        }

        table#tblEmpClaimLevel.dataTable tbody th {
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

        #tblEmpClaimLevel {
            margin-top: 0px !important;
        }

         

        .tdUpdateBy, .tdBeatEmp, .tdRegion, .tdRemarks {
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

            .tdRemarks::-webkit-scrollbar {
                display: none;
            }
      
        .tdUpdateBy, .tdBeatEmp, .tdRegion, .tdRemarks {
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
         #gvEmpClaimLevelHistory_wrapper .dataTables_scrollBody {
            overflow-x: auto !important;
            overflow-y: auto !important;
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

        /*#gvEmpClaimLevelHistory {
            margin-left: 0px !important;
            width: 1432px !important;
        }
*/
        @media (min-width: 1200px) {
            #gvEmpClaimLevelHistory_wrapper .dataTables_scrollHead {
                width: 1300px !important;
            }

            #gvEmpClaimLevelHistory_wrapper .dataTables_scrollFootInner {
                width: 1300px !important;
            }

            #gvEmpClaimLevelHistory_wrapper.dataTables_scrollBody {
                width: 1300px !important;
                overflow: hidden !important;
            }

            #gvEmpClaimLevelHistory_wrapper .dataTables_scrollFoot {
                width: 1300px !important;
            }
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
                    <div class="col-lg-2" style="display:none;">
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
            <div class="row _masterForm">
                <div class="col-lg-12">
                    <input type="hidden" id="CountRowUserUnit" />
                    <div id="divEmpClaimLevel" class="divEmpClaimLevel" runat="server" style="max-height: 50vh; position: absolute;">
                        <table id="tblEmpClaimLevel" class="table table-bordered nowrap" border="1" tabindex="8" style="border-collapse: collapse; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="width: 3% !important; text-align: center;">Sr</th>
                                    <th style="text-align: center;">Edit</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Remarks 1</th>
                                    <th style="width: 20%; padding-left: 10px !important;">Remarks 2</th>
                                    <%--<th style="width: 20%; padding-left: 10px !important;">Dealer</th>--%>
                                   <%-- <th style="width: 3% !important; text-align: center; padding-left: 3px !important;">Active</th>--%>
                                   <%-- <th style="width: 3% !important; text-align: center; padding-left: 3px !important;">Include</th>--%>
                                    <th style="width: 20%; padding-left: 10px !important;">From Date</th>
                                    <th style="width: 20%; padding-left: 10px !important;">To Date</th>
                                    <th style="width: 7%; padding-left: 5px !important;">Updated By</th>
                                    <th style="width: 7%; text-align: center;">Update Date / Time</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div id="divEmpClaimLevelReport" class="divEmpClaimLevelReport" style="max-height: 50vh; overflow-y: auto;">
                        <table id="gvEmpClaimLevelHistory" class="gvEmpClaimLevelHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="text-align: center; width: 2%;">Sr</th>
                                    <th style="width: 10%">Remarks-1</th>
                                    <th style="width: 10%">Remarks-2</th>
                                    <th style="width: 10%">Dealer</th>
                                    <th style="width: 3%;">Active</th>
                                    <th style="width: 3%;">Include</th>
                                    <th style="width: 10%">From Date</th>
                                    <th style="width: 10%">To Date</th>
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
        </div>
    </div>
</asp:Content>

