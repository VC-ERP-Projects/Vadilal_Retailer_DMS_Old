<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="DiscountTypeIncExcMaster.aspx.cs" Inherits="Master_DiscountTypeIncExcMaster" %>

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
        var LogoURL = '../Images/LOGO.png';
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
            $("#tblDiscountExc").tableHeadFixer('80vh');
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

            var aryJSONColTable = [];

            aryJSONColTable.push({ "width": "13px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 2 });
            aryJSONColTable.push({ "width": "100px", "aTargets": 3 });
            aryJSONColTable.push({ "width": "110px", "aTargets": 4 });
            aryJSONColTable.push({ "width": "110px", "aTargets": 5 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "width": "120px", "aTargets": 6 });
            aryJSONColTable.push({ "width": "120px", "aTargets": 7 });
            aryJSONColTable.push({ "width": "90px", "aTargets": 8 });
            aryJSONColTable.push({ "width": "90px", "aTargets": 9 });
            aryJSONColTable.push({ "width": "90px", "aTargets": 10 });
            aryJSONColTable.push({ "width": "90px", "aTargets": 11 });
            aryJSONColTable.push({ "width": "130px", "aTargets": 12 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 13 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 14 });
            aryJSONColTable.push({ "width": "17px", "aTargets": 15 });
            aryJSONColTable.push({ "width": "18px", "aTargets": 16 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 17 });
            aryJSONColTable.push({ "width": "25px", "aTargets": 18 });
            aryJSONColTable.push({ "width": "19px", "aTargets": 19 });
            aryJSONColTable.push({ "width": "25px", "aTargets": 20 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 21 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 22 });
            aryJSONColTable.push({ "width": "40px", "aTargets": 23 });
            aryJSONColTable.push({ "width": "40px", "aTargets": 24 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 25 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 26 });
            aryJSONColTable.push({ "width": "90px", "aTargets": 27 });
            aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyCenter", "aTargets": 28 });
            aryJSONColTable.push({ "width": "90px", "aTargets": 29 });
            aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyCenter", "aTargets": 30 });

            $('#tblDiscountExc').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "sExtends": "collection",
                scrollX: true,
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": false,
                "autoWidth": false,
                destroy: true,
                "aoColumnDefs": aryJSONColTable,
            });

            //$('#tblDiscountExc').DataTable({
            //    scrollY:false,
            //    scrollX: true,
            //    "paging": false,
            //    "bInfo": false,
            //    ordering: false,
            //});
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
                //$('#tblDiscountExc').find('th:nth-child(6)').hide();
                $('.thSS').hide();
                $('.tdSS').hide();
                $('.tdSTOD').hide();
                $('.thSTOD').hide();
                $('.thCustomer').show();
                $('.tdCustomer').show();


                $('.thQPS').show();
                $('.tdQPS').show();
                $('.thMachine').show();
                $('.tdMachine').show();
                $('.thParlour').show();
                $('.tdParlour').show();

                // Below Checkbox Temp Hide.
                $('.thFOW').hide();
                $('.tdFOW').hide();
                $('.thSecFright').hide();
                $('.tdSecFrieght').hide();
                $('.thVRS').hide();
                $('.tdVRS').hide();
                $('.thRateDiff').hide();
                $('.tdRateDiff').hide();
                $('.thIOU').hide();
                $('.tdIOU').hide();
                //$('#tblDiscountExc').find('th:nth-child(8)').show();
                //$('.tdCustomer').show();
                ClearClaimRow();

            }
            else if (option == 2) {

                //$('#tblDiscountExc').find('th:nth-child(6)').show();
                $('.thSS').show();
                $('.tdSS').show();
                $('.thSTOD').show();
                $('.tdSTOD').show();
                $('.thCustomer').hide();
                $('.tdCustomer').hide();


                $('.thQPS').hide();
                $('.tdQPS').hide();
                $('.thMachine').hide();
                $('.tdMachine').hide();
                $('.thParlour').hide();
                $('.tdParlour').hide();
                $('.thFOW').hide();
                $('.tdFOW').hide();
                $('.thSecFright').hide();
                $('.tdSecFrieght').hide();
                $('.thVRS').hide();
                $('.tdVRS').hide();
                $('.thRateDiff').hide();
                $('.tdRateDiff').hide();
                $('.thIOU').hide();
                $('.tdIOU').hide();
                //$('#tblDiscountExc').find('th:nth-child(9)').hide();
                //$('.tdCustomer').hide();
                ClearClaimRow();

            }
            ClearControls();
            $('#hdnDeleteIDs').val('');
            $('#hdnIsRowDeleted').val("0");

        }
        function ShowDistOrSS() {

            var option = $(".ddlOption").val();

            if (option == 1) {
                // $('#tblDiscountExc').find('th:nth-child(6)').hide();
                $('.thSS').hide();
                $('.tdSS').hide();
                $('.tdSTOD').hide();
                $('.thSTOD').hide();
                ClearClaimRow();

                $('.thQPS').show();
                $('.tdQPS').show();
                $('.thMachine').show();
                $('.tdMachine').show();
                $('.thParlour').show();
                $('.tdParlour').show();
                $('.thFOW').hide();
                $('.tdFOW').hide();
                $('.thSecFright').hide();
                $('.tdSecFrieght').hide();
                $('.thVRS').hide();
                $('.tdVRS').hide();
                $('.thRateDiff').hide();
                $('.tdRateDiff').hide();
                $('.thIOU').hide();
                $('.tdIOU').hide();


                $('.thCustomer').show();
                $('.tdCustomer').show();
                //$('#tblDiscountExc').find('th:nth-child(8)').show();
                //$('.tdCustomer').show();
            }
            else if (option == 2) {
                // $('#tblDiscountExc').find('th:nth-child(6)').show();
                $('.thSS').show();
                $('.tdSS').show();
                $('.thSTOD').show();
                $('.tdSTOD').show();
                ClearClaimRow();
                $('.thCustomer').hide();
                $('.tdCustomer').hide();



                $('.thQPS').hide();
                $('.tdQPS').hide();
                $('.thMachine').hide();
                $('.tdMachine').hide();
                $('.thParlour').hide();
                $('.tdParlour').hide();
                $('.thFOW').hide();
                $('.tdFOW').hide();
                $('.thSecFright').hide();
                $('.tdSecFrieght').hide();
                $('.thVRS').hide();
                $('.tdVRS').hide();
                $('.thRateDiff').hide();
                $('.tdRateDiff').hide();
                $('.thIOU').hide();
                $('.tdIOU').hide();
                //$('#tblDiscountExc').find('th:nth-child(9)').hide();
                //$('.tdCustomer').hide();

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
            $('table#tblDiscountExc tr#NoROW').remove();  // Remove NO ROW
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
                + "<td><input type='text' id='AutoEmpName" + ind + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdRegion'><input type='text' id='AutoRegion" + ind + "' name='AutoRegion' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdSS'><input type='text' id='AutoSSName" + ind + "' name='AutoSSName' onchange='ChangeData(this);' class='form-control search SS' /></td>"
                + "<td class='tdDist'><input type='text' id='AutoDistName" + ind + "' name='AutoDistName' onchange='ChangeData(this);' class='form-control search Dist' /></td>"
                + "<td class='tdCustGroup'><input type='text' id='AutoCustGroup" + ind + "' name='AutoCustGroup' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdCustomer'><input type='text' id='AutoCustomer" + ind + "' name='AutoCustomer' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdDivision'><input type='text' id='AutoDivision" + ind + "' name='AutoDivision' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdProdGroup'><input type='text' id='AutoProdGrp" + ind + "' name='AutoProdGrp' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdProdSubGroup'><input type='text' id='AutoProdSubGrp" + ind + "' name='AutoProdSubGrp' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdItemCode'><input type='text' id='AutoItemCode" + ind + "' name='AutoItemCode' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td class='tdMaster'><input type='checkbox' id='chkMaster" + ind + "' name='chkMaster' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdQPS'><input type='checkbox' id='chkQPS" + ind + "' name='chkQPS' onchange='ChangeData(this);'  class='checkbox'/></td>"

                + "<td class='tdMachine'><input type='checkbox' id='chkMachine" + ind + "' name='chkMachine' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdParlour'><input type='checkbox' id='chkParlour" + ind + "' name='chkParlour' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdFOW'><input type='checkbox' id='chkFOW" + ind + "' name='chkFOW' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdSecFrieght'><input type='checkbox' id='chkSecFrieght" + ind + "' name='chkSecFrieght' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdVRS'><input type='checkbox' id='chkVRS" + ind + "' name='chkVRS' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdRateDiff'><input type='checkbox' id='chkRateDiff" + ind + "' name='chkRateDiff' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdIOU'><input type='checkbox' id='chkIOU" + ind + "' name='chkIOU' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td class='tdSTOD'><input type='checkbox' id='chkSTOD" + ind + "' name='chkSTOD' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td ><input readonly type='text' id='tdFromDate" + ind + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search dtbodyCenter' onpaste='return false;'/></td>"
                + "<td><input readonly type='text' id='tdToDate" + ind + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' onpaste='return false;'/></td>"
                 + "<td><input type='checkbox' id='chkInclude" + ind + "' name='chkInclude' onchange='ChangeData(this);'  class='checkbox'/></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"
              // + "<td id='tdUniqueNo" + ind + "' class='tdUniqueNo'></td>"
                + "<td id='tdCreatedBy" + ind + "' class='tdCreatedBy'></td>"
                + "<td id='tdCreatedDate" + ind + "' class='tdCreatedDate'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDate" + ind + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnDiscountExcId' id='hdnDiscountExcId" + ind + "' name='hdnDiscountExcId'/></td>"
                + "<input type='hidden' class='hdnRegionId' id='hdnRegionId" + ind + "' name='hdnRegionId'  /></td>"
                + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + ind + "' name='hdnEmpId'  /></td>"
                + "<input type='hidden' class='hdnDistId' id='hdnDistId" + ind + "' name='hdnDistId'  /></td>"
                + "<input type='hidden' class='hdnSSId' id='hdnSSId" + ind + "' name='hdnSSId'  /></td>"
                + "<input type='hidden' class='hdnCustGroupId' id='hdnCustGroupId" + ind + "' name='hdnCustGroupId'  /></td>"
                + "<input type='hidden' class='hdnCustomerId' id='hdnCustomerId" + ind + "' name='hdnCustomerId'  /></td>"
                + "<input type='hidden' class='hdnDivisionId' id='hdnDivisionId" + ind + "' name='hdnDivisionId'  /></td>"
                + "<input type='hidden' class='hdnProdGrpId' id='hdnProdGrpId" + ind + "' name='hdnProdGrpId'  /></td>"
                + "<input type='hidden' class='hdnProdSubGrpId' id='hdnProdSubGrpId" + ind + "' name='hdnProdSubGrpId'  /></td>"
                + "<input type='hidden' class='hdnItemCode' id='hdnItemCode" + ind + "' name='hdnItemCode'  /></td>"
                + "<input type='hidden' class='IsChange' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";

            $('#tblDiscountExc > tbody').append(str);
            ShowDistOrSS();
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);


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


            // $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
            var table = document.getElementById("tblDiscountExc");
            //Start Region Textbox
            $('#AutoRegion' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: 'DiscountTypeIncExcMaster.aspx/SearchRegion',
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
                select: function (event, ui) {
                    //$('#hdnRegionId' + ind).val(0);
                    //$('#AutoRegion' + ind).val("");
                    $('#hdnRegionId' + ind).val(ui.item.id);
                    // $('#hdnEmpID' + ind).val(ui.item.value.split('#')[2].trim());
                    $('#AutoRegion' + ind).val(ui.item.value + " ");
                    //  $('#AutoEmpName' + ind).val("");
                    // $('#hdnEmpId' + ind).val(0);
                    $('#AutoDistName' + ind).val("");
                    $('#hdnDistId' + ind).val(0);
                    $('#AutoSSName' + ind).val("");
                    $('#hdnSSId' + ind).val(0);
                    $('#AutoCustomer' + ind).val("");
                    $('#hdnCustomerId' + ind).val(0);
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoRegion' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoRegion' + ind).position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},

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
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 1, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });

            //Start Employee  Textbox
            $('#AutoEmpName' + ind).autocomplete({
                source: function (request, response) {
                    var RegionId = $("#AutoRegion" + ind).val() != "" && $("#AutoRegion" + ind).val() != undefined ? $("#AutoRegion" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchEmployee',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strRegionId':'" + RegionId + "'}",
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
                    $('#AutoDistName' + ind).val("");
                    $('#hdnDistId' + ind).val(0);
                    $('#AutoSSName' + ind).val("");
                    $('#hdnSSId' + ind).val(0);
                    $('#AutoCustomer' + ind).val("");
                    $('#hdnCustomerId' + ind).val(0);
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoEmpName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoEmpName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},

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
                    if ($('#AutoEmpName' + ind).val().indexOf('#') == -1) {
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
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 2, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });

            //End Employee Textbox

            //Start Distributor Textbox           
            $('#AutoDistName' + ind).autocomplete({
                source: function (request, response) {
                    var EmpId = $("#AutoEmpName" + ind).val() != "" && $("#AutoEmpName" + ind).val() != undefined ? $("#AutoEmpName" + ind).val().split("#")[2].trim() : "0";
                    var RegionId = $("#AutoRegion" + ind).val() != "" && $("#AutoRegion" + ind).val() != undefined ? $("#AutoRegion" + ind).val().split("-")[2].trim() : "0";
                    var SSID = $("#AutoSSName" + ind).val() != "" && $("#AutoSSName" + ind).val() != undefined ? $("#AutoSSName" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchDistributor',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "','strSSID':'" + SSID + "'}",
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
                    $('#AutoCustomer' + ind).val("");
                    $('#hdnCustomerId' + ind).val(0);
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoDistName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoDistName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
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
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 3, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Distributor textbox
            //Start SuperStockiest textBox
            $('#AutoSSName' + ind).autocomplete({
                source: function (request, response) {
                    var EmpId = $("#AutoEmpName" + ind).val() != "" && $("#AutoEmpName" + ind).val() != undefined ? $("#AutoEmpName" + ind).val().split("#")[2].trim() : "0";
                    var RegionId = $("#AutoRegion" + ind).val() != "" && $("#AutoRegion" + ind).val() != undefined ? $("#AutoRegion" + ind).val().split("-")[2].trim() : "0";

                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchSuperStockiest',
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

                    $('#AutoSSName' + ind).val(ui.item.value + " ");
                    $('#hdnSSId' + ind).val(ui.item.value.split("-")[2].trim());
                    $('#tdFromDate' + ind).text('');

                    $('#AutoDistName' + ind).val("");
                    $('#hdnDistId' + ind).val(0);
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
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
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 4, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End SuperStockiest textbox



            //Start CustomerGroup textBox
            $('#AutoCustGroup' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchCustomerGroup',
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
                select: function (event, ui) {
                    $('#AutoCustGroup' + ind).val(ui.item.value + " ");
                    $('#hdnCustGroupId' + ind).val(ui.item.value.split("#")[2].trim());
                    $('#tdFromDate' + ind).text('');
                    $('#tdToDate' + ind).text('');
                    $('#AutoCustomer' + ind).val("");
                    $('#hdnCustomerId' + ind).val(0);
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoCustGroup' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoCustGroup' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoCustGroup' + ind).on('change keyup', function () {
                if ($('#AutoCustGroup' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnCustGroupId' + ind).val(0);

                }
            });

            $('#AutoCustGroup' + ind).on('blur', function (e, ui) {
                if ($('#AutoCustGroup' + ind).val().trim() != "") {
                    if ($('#AutoCustGroup' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Customer Group", 3);
                        $('#AutoCustGroup' + ind).val("");
                        $('#hdnCustGroupId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoCustGroup' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 5, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Customer Group textbox


            //Start Customer textBox
            $('#AutoCustomer' + ind).autocomplete({
                source: function (request, response) {
                    var EmpId = $("#AutoEmpName" + ind).val() != "" && $("#AutoEmpName" + ind).val() != undefined ? $("#AutoEmpName" + ind).val().split("#")[2].trim() : "0";
                    var RegionId = $("#AutoRegion" + ind).val() != "" && $("#AutoRegion" + ind).val() != undefined ? $("#AutoRegion" + ind).val().split("-")[2].trim() : "0";
                    var DistId = $("#AutoDistName" + ind).val() != "" && $("#AutoDistName" + ind).val() != undefined ? $("#AutoDistName" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchCustomerData',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpId':'" + EmpId + "','strRegionId':'" + RegionId + "','strDistId':'" + DistId + "'}",
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
                    $('#AutoCustomer' + ind).val(ui.item.value + " ");
                    $('#hdnCustomerId' + ind).val(ui.item.value.split("-")[2].trim());
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoCustomer' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoCustomer' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoCustomer' + ind).on('change keyup', function () {
                if ($('#AutoCustomer' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnCustomerId' + ind).val(0);

                }
            });

            $('#AutoCustomer' + ind).on('blur', function (e, ui) {
                if ($('#AutoCustomer' + ind).val().trim() != "") {
                    if ($('#AutoCustomer' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Customer", 3);
                        $('#AutoCustomer' + ind).val("");
                        $('#hdnCustomerId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoCustomer' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 6, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Customer textbox


            //Start Division textBox
            $('#AutoDivision' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchDivision',
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
                select: function (event, ui) {
                    $('#AutoDivision' + ind).val(ui.item.value + " ");
                    $('#hdnDivisionId' + ind).val(ui.item.value.split("#")[2].trim());
                    //$('#AutoProdGrp' + ind).val("");
                    //$('#AutoProdSubGrp' + ind).val("");
                    //$('#AutoItemCode' + ind).val("");

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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoDivision' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoDivision' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoDivision' + ind).on('change keyup', function () {
                if ($('#AutoDivision' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnDivisionId' + ind).val(0);

                }
            });

            $('#AutoDivision' + ind).on('blur', function (e, ui) {
                if ($('#AutoDivision' + ind).val().trim() != "") {
                    if ($('#AutoDivision' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Division", 3);
                        $('#AutoDivision' + ind).val("");
                        $('#hdnDivisionId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoDivision' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 7, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Division textbox



            //Start Product Group textBox
            $('#AutoProdGrp' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchProductGroup',
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
                select: function (event, ui) {
                    $('#AutoProdGrp' + ind).val(ui.item.value + " ");
                    $('#hdnProdGrpId' + ind).val(ui.item.value.split("#")[1].trim());
                    $('#AutoProdSubGrp' + ind).val("");
                    $('#AutoItemCode' + ind).val("");

                    $('#hdnItemCode' + ind).val(0);
                    $('#hdnProdSubGrpId' + ind).val(0);

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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoProdGrp' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoProdGrp' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoProdGrp' + ind).on('change keyup', function () {
                if ($('#AutoProdGrp' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnProdGrpId' + ind).val(0);

                }
            });

            $('#AutoProdGrp' + ind).on('blur', function (e, ui) {
                if ($('#AutoProdGrp' + ind).val().trim() != "") {
                    if ($('#AutoProdGrp' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Product Group", 3);
                        $('#AutoProdGrp' + ind).val("");
                        $('#hdnProdGrpId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoProdGrp' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 8, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Product Group textbox


            //Start Product Sub Group textBox
            $('#AutoProdSubGrp' + ind).autocomplete({
                source: function (request, response) {
                    var ProdGrpId = $("#AutoProdGrp" + ind).val() != "" && $("#AutoProdGrp" + ind).val() != undefined ? $("#AutoProdGrp" + ind).val().split("#")[1].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchProductSubGroup',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strProdGroupId':'" + ProdGrpId + "'}",
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
                    $('#AutoProdSubGrp' + ind).val(ui.item.value + " ");
                    $('#hdnProdSubGrpId' + ind).val(ui.item.value.split("#")[1].trim());
                    $('#AutoItemCode' + ind).val("");
                    $('#hdnItemCode' + ind).val(0);
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoProdSubGrp' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoProdSubGrp' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoProdSubGrp' + ind).on('change keyup', function () {
                if ($('#AutoProdSubGrp' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnProdSubGrpId' + ind).val(0);

                }
            });

            $('#AutoProdSubGrp' + ind).on('blur', function (e, ui) {
                if ($('#AutoProdSubGrp' + ind).val().trim() != "") {
                    if ($('#AutoProdSubGrp' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Product Sub Group", 3);
                        $('#AutoProdSubGrp' + ind).val("");
                        $('#hdnProdSubGrpId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoProdSubGrp' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 9, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Product Sub Group textbox

            //Start Item textBox
            $('#AutoItemCode' + ind).autocomplete({
                source: function (request, response) {
                    var ProdGrpId = $("#AutoProdGrp" + ind).val() != "" && $("#AutoProdGrp" + ind).val() != undefined ? $("#AutoProdGrp" + ind).val().split("#")[1].trim() : "0";
                    var ProdSubGrpId = $("#AutoProdSubGrp" + ind).val() != "" && $("#AutoProdSubGrp" + ind).val() != undefined ? $("#AutoProdSubGrp" + ind).val().split("#")[1].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'DiscountTypeIncExcMaster.aspx/SearchItemCode',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strProdGroupId':'" + ProdGrpId + "','strProdSubGroupId':'" + ProdSubGrpId + "'}",
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
                    $('#AutoItemCode' + ind).val(ui.item.value + " ");
                    $('#hdnItemCode' + ind).val(ui.item.value.split("#")[0].trim());
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
                //open: function (event, ui) {
                //    var txttopposition = $('#AutoSSName' + ind).position().top;
                //    var bottomPosition = $(document).height();
                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //        inputHeight = $input.height(),
                //        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoSSName' + ind).position().top : table.offsetHeight,
                //        height = $results.height(),
                //        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoItemCode' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoItemCode' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoItemCode' + ind).on('change keyup', function () {
                if ($('#AutoItemCode' + ind).val() == "") {
                    ClearClaimRow(ind);
                    $('#hdnItemCode' + ind).val(0);

                }
            });

            $('#AutoItemCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoItemCode' + ind).val().trim() != "") {
                    if ($('#AutoItemCode' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Item", 3);
                        $('#AutoItemCode' + ind).val("");
                        $('#hdnItemCode' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoItemCode' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateData($('#AutoRegion' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoDistName' + ind).val().trim(), $('#AutoSSName' + ind).val().trim(), ind, 10, $('#AutoCustGroup' + ind).val().trim(), $('#AutoCustomer' + ind).val().trim(), $('#AutoDivision' + ind).val().trim(), $('#AutoProdGrp' + ind).val().trim(), $('#AutoProdSubGrp' + ind).val().trim(), $('#AutoItemCode' + ind).val().trim());
                }
            });
            //End Item textbox
        }

        function CheckDuplicateData(pRegioCode, pEmpCode, pDistCode, pSSCode, row, ChkType, pCustGroup, pCustomer, pDivision, pProdGrp, pProdSubGrp, pItemCode) {
            var Item = "", ItmEmpCode = "", ItmDistCode = "", ItmSSCode = "", ItmCustGroup = "", ItmCust = "0", ItmDivision = "0", ItmProdGrp = "0", ItmProdSubGrp = "0", ItmCode = "";

            if (pRegioCode != "") {
                Item = pRegioCode.split("-")[2].trim();
            }
            if (pEmpCode != "") {
                ItmEmpCode = pEmpCode.split("#")[2].trim();
            }

            if (pDistCode != "") {
                ItmDistCode = pDistCode.split("-")[2].trim();
            }
            if (pSSCode != "") {
                ItmSSCode = pSSCode.split("-")[2].trim();
            }
            if (pCustGroup != "") {
                ItmCustGroup = pCustGroup.split("#")[2].trim();
            }
            if (pCustomer != "") {
                ItmCust = pCustomer.split("-")[2].trim();
            }
            if (pDivision != "") {
                ItmDivision = pDivision.split("#")[2].trim();
            }
            if (pProdGrp != "") {
                ItmProdGrp = pProdGrp.split("#")[1].trim();
            }
            if (pProdSubGrp != "") {
                ItmProdSubGrp = pProdSubGrp.split("#")[1].trim();
            }
            if (pItemCode != "") {
                ItmCode = pItemCode.split("#")[0].trim();
            }

            var rowCnt_Claim = 1;
            var cnt = 0;
            var errRow = 0;
            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
                var RegionCode = $("input[name='AutoRegion']", this).val() != "" ? $("input[name='AutoRegion']", this).val().split("-")[2].trim() : "";
                var EmpCode = $("input[name='AutoEmpName']", this).val() != "" ? $("input[name='AutoEmpName']", this).val().split("#")[2].trim() : "";
                var DistCode = $("input[name='AutoDistName']", this).val() != "" ? $("input[name='AutoDistName']", this).val().split("-")[2].trim() : "";
                var SSCode = $("input[name='AutoSSName']", this).val() != "" ? $("input[name='AutoSSName']", this).val().split("-")[2].trim() : "";

                var CustGroup = $("input[name='AutoCustGroup']", this).val() != "" ? $("input[name='AutoCustGroup']", this).val().split("#")[2].trim() : "";
                var Customer = $("input[name='AutoCustomer']", this).val() != "" ? $("input[name='AutoCustomer']", this).val().split("-")[2].trim() : "";
                var Division = $("input[name='AutoDivision']", this).val() != "" ? $("input[name='AutoDivision']", this).val().split("#")[2].trim() : "";
                var ProdGroup = $("input[name='AutoProdGrp']", this).val() != "" ? $("input[name='AutoProdGrp']", this).val().split("#")[1].trim() : "";
                var ProdSubGroup = $("input[name='AutoProdSubGrp']", this).val() != "" ? $("input[name='AutoProdSubGrp']", this).val().split("#")[1].trim() : "";
                var ItemCode = $("input[name='AutoItemCode']", this).val() != "" ? $("input[name='AutoItemCode']", this).val().split("#")[0].trim() : "";

                var LineNum = $("input[name='hdnLineNum']", this).val();
                var RgnId = $("input[name='hdnRegionId']", this).val();
                var EmpId = $("input[name='hdnEmpId']", this).val();
                var DistId = $("input[name='hdnDistId']", this).val();
                var SSId = $("input[name='hdnSSId']", this).val();


                var CustGrpId = $("input[name='hdnCustGroupId']", this).val();
                var CustId = $("input[name='hdnCustomerId']", this).val();
                var DivId = $("input[name='hdnDivisionId']", this).val() == "" ? 0 : $("input[name='hdnDivisionId']", this).val();
                var PGrpId = $("input[name='hdnProdGrpId']", this).val() == "" ? 0 : $("input[name='hdnProdGrpId']", this).val();
                var PSubGrpId = $("input[name='hdnProdSubGrpId']", this).val() == "" ? 0 : $("input[name='hdnProdSubGrpId']", this).val();
                var pItemId = $("input[name='hdnItemCode']", this).val() == "" ? 0 : $("input[name='hdnItemCode']", this).val();

                if (parseInt(row) != parseInt(LineNum)) {
                    debugger;
                    if (Item == RegionCode && ItmEmpCode == EmpCode && ItmDistCode == DistCode && ItmSSCode == SSCode
                        && ItmCustGroup == CustGroup && ItmCust == CustId && ItmDivision == DivId && ItmProdGrp == PGrpId
                        && ItmProdSubGrp == PSubGrpId && ItmCode == ItemCode
                        ) {
                        cnt = 1;
                        errRow = row;
                        $('#AutoRegion' + ind).val("");
                        $('#hdnRegionId' + ind).val(0);
                        $('#chkIsActive' + row).prop('checked', false);
                        $('#chkIsActive' + row).attr("disabled", false);
                        errormsg = 'Data is already set for at row : ' + rowCnt_Claim;
                        return false;
                    }
                }

                //if (ChkType == 1) {
                //    if (RgnId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (Item == RegionCode) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoRegion' + ind).val("");
                //                $('#hdnRegionId' + ind).val(0);
                //                $('#chkIsActive' + row).prop('checked', false);
                //                $('#chkIsActive' + row).attr("disabled", false);
                //                errormsg = 'Region is already set for = ' + pRegioCode + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 2) {

                //    if (EmpCode != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pEmpCode.split("-")[2].trim() == EmpCode) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoEmpName' + row).val('');
                //                // $('#hdnEmpId' + ind).val(0);
                //                errormsg = 'Employee is already set for = ' + pEmpCode + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 3) {
                //    if (DistId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pDistCode.split("-")[2].trim() == DistCode) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoDistName' + row).val('');
                //                errormsg = 'Distributor is already set = ' + pDistCode + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 4) {
                //    if (SSId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pSSCode.split("-")[2].trim() == SSCode) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoSSName' + row).val('');
                //                errormsg = 'Super Stockist is already set for = ' + pSSCode + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 5) {
                //    if (CustGroup != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pCustGroup.split("#")[2].trim() == CustGroup) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoCustGroup' + row).val('');
                //                errormsg = 'Customer Group is already set for = ' + pCustGroup + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 6) {
                //    if (CustId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pCustomer.split("-")[2].trim() == CustId) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoCustomer' + row).val('');
                //                errormsg = 'Customer is already set for = ' + pCustomer + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 7) {
                //    if (DivId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pDivision.split("#")[2].trim() == DivId) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoDivision' + row).val('');
                //                errormsg = 'Division is already set for = ' + pDivision + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 8) {
                //    if (PGrpId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pProdGrp.split("#")[1].trim() == PGrpId) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoProdGrp' + row).val('');
                //                errormsg = 'Product Group is already set for = ' + pProdGrp + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 9) {
                //    if (PSubGrpId != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pProdSubGrp.split("#")[1].trim() == PSubGrpId) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoProdSubGrp' + row).val('');
                //                errormsg = 'Product Sub Group is already set for = ' + pProdSubGrp + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
                //else if (ChkType == 10) {
                //    if (pItemCode != "") {
                //        if (parseInt(row) != parseInt(LineNum)) {
                //            if (pItemCode.split("#")[0].trim() == ItemCode) {
                //                cnt = 1;
                //                errRow = row;
                //                $('#AutoItemCode' + row).val('');
                //                errormsg = 'Item is already set for = ' + pItemCode + ' at row : ' + rowCnt_Claim;
                //                return false;
                //            }
                //        }
                //    }
                //}
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
                else if (ChkType == 4) {
                    $('#AutoSSName' + row).val('');
                }
                else if (ChkType == 5) {
                    $('#AutoCustGroup' + row).val('');
                }
                else if (ChkType == 6) {
                    $('#AutoCustomer' + row).val('');
                }
                else if (ChkType == 7) {
                    $('#AutoDivision' + row).val('');
                }
                else if (ChkType == 8) {
                    $('#AutoProdGrp' + row).val('');
                }
                else if (ChkType == 9) {
                    $('#AutoProdSubGrp' + row).val('');
                }
                else {
                    $('#AutoItemCode' + row).val('');
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
            $('#tblDiscountExc > tbody > tr').each(function (row1, tr) {
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
                $('#tblDiscountExc > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Claim) {
                        var DiscountExcId = $("input[name='hdnDiscountExcId']", this).val();
                        var RegionName = $("input[name='AutoRegion']", this).val();
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        var DistName = $("input[name='AutoDistName']", this).val();
                        var SSName = $("input[name='AutoSSName']", this).val();

                        var CustGroup = $("input[name='AutoCustGroup']", this).val();
                        var Customer = $("input[name='AutoCustomer']", this).val();
                        var Divsion = $("input[name='AutoDivision']", this).val();
                        var ProdGroup = $("input[name='AutoProdGrp']", this).val();
                        var ProdSubGroup = $("input[name='AutoProdSubGrp']", this).val();
                        var ItemCode = $("input[name='AutoItemCode']", this).val();

                        if (RegionName == "" && EmpName == "" && DistName == "" && SSName == "" && CustGroup == "" && Customer == "" && Divsion == "" && ProdGroup == "" && ProdSubGroup == "" && ItemCode == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Claim++;
                });
            }
            var lineNum = 1;
            $('#tblDiscountExc > tbody > tr').each(function (row, tr) {
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
            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                $(this).remove();
            });

            var IsValid = true;
            $.ajax({
                url: 'DiscountTypeIncExcMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                //data: JSON.stringify({ OptionId: $('.ddlOption').val(), DiscountType: $('.ddlDiscountType').val() }),
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

                        //var items =result.d;//result.d[0];

                        var items = JSON.parse(result.d)

                        // console.log(items);

                        if (items.length > 0) {
                            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
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
                            var length = 0;
                            // $('#CountRowClaim').val(0);
                            $.each(items, function () {
                                var itm = this;
                                //for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowClaim').val();
                                $('#chkEdit' + row).click();
                                $('#chkEdit' + row).prop("checked", false);

                                //$('#AutoRegion' + row).val(items[i].Region);
                                //$('#AutoEmpName' + row).val(items[i].EmpName);
                                //$('#AutoDistName' + row).val(items[i].DistName);
                                //$('#AutoSSName' + row).val(items[i].SSName);
                                //$('#days' + row).val(items[i].Days);

                                $('#AutoRegion' + row).val(itm.Region);
                                $('#AutoEmpName' + row).val(itm.EmpName);
                                $('#AutoDistName' + row).val(itm.Distributor);
                                $('#AutoSSName' + row).val(itm.SSName);


                                $('#AutoCustGroup' + row).val(itm.CustGroupName);
                                $('#AutoCustomer' + row).val(itm.CustomerName);
                                $('#AutoDivision' + row).val(itm.DivisionName);
                                $('#AutoProdGrp' + row).val(itm.ItemGroupName);
                                $('#AutoProdSubGrp' + row).val(itm.ItemSubGroupName);
                                $('#AutoItemCode' + row).val(itm.ItemName);


                                if (itm.MasterSchm == false) {
                                    $('#chkMaster' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkMaster' + row).prop("checked", true);
                                }

                                if (itm.QPS == false) {
                                    $('#chkQPS' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkQPS' + row).prop("checked", true);
                                }

                                if (itm.Machine == false) {
                                    $('#chkMachine' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkMachine' + row).prop("checked", true);
                                }

                                if (itm.Parlour == false) {
                                    $('#chkParlour' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkParlour' + row).prop("checked", true);
                                }

                                if (itm.FOW == false) {
                                    $('#chkFOW' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkFOW' + row).prop("checked", true);
                                }

                                if (itm.SecFright == false) {
                                    $('#chkSecFrieght' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkSecFrieght' + row).prop("checked", true);
                                }

                                if (itm.VRS == false) {
                                    $('#chkVRS' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkVRS' + row).prop("checked", true);
                                }


                                if (itm.RateDiff == false) {
                                    $('#chkRateDiff' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkRateDiff' + row).prop("checked", true);
                                }

                                if (itm.IOU == false) {
                                    $('#chkIOU' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkIOU' + row).prop("checked", true);
                                }

                                if (itm.STOD == false) {
                                    $('#chkSTOD' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkSTOD' + row).prop("checked", true);
                                }

                                $('#tdFromDate' + row).val(itm.FromDate);
                                $('#tdToDate' + row).val(itm.ToDate);

                                if (itm.IsInclude == false) {
                                    $('#chkInclude' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkInclude' + row).prop("checked", true);
                                }

                                // $('#AutoCustName' + row).val(items[i].CustomerName);                               
                                // console.log(itm.Active);
                                // if (items[i].IsActive == false) {
                                if (itm.Active == false) {
                                    $('#chkIsActive' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkIsActive' + row).prop("checked", true);
                                }




                                //$('#tdCreatedBy' + row).text(items[i].CreatedBy);
                                //$('#tdCreatedDate' + row).text(items[i].CreatedDate);
                                //$('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                //$('#tdUpdateDate' + row).text(items[i].UpdatedDate);
                                //$('#hdnDiscountExcId' + row).val(items[i].DiscountExcId);
                                //$('#hdnRegionId' + row).val(items[i].RegionId);
                                //$('#hdnEmpId' + row).val(items[i].EmpId);
                                //$('#hdnDistId' + row).val(items[i].DistributorId);
                                //$('#hdnSSId' + row).val(items[i].SSID);

                                //  $('#tdUniqueNo' + row).text(itm.DiscountExcId);
                                $('#tdCreatedBy' + row).text(itm.CreatedBy);
                                $('#tdCreatedDate' + row).text(itm.CreatedDate);
                                $('#tdUpdateBy' + row).text(itm.UpdatedBy);
                                $('#tdUpdateDate' + row).text(itm.UpdatedDate);
                                $('#hdnDiscountExcId' + row).val(itm.DiscountExcId);
                                $('#hdnRegionId' + row).val(itm.RegionId);
                                $('#hdnEmpId' + row).val(itm.EmpId);
                                $('#hdnDistId' + row).val(itm.DistributorId);
                                $('#hdnSSId' + row).val(itm.SSID);



                                $('#hdnCustGroupId' + row).val(itm.CustGroupId);
                                $('#hdnCustomerId' + row).val(itm.CustomerId);
                                $('#hdnDivisionId' + row).val(itm.Division);
                                $('#hdnProdGrpId' + row).val(itm.ProductGroupId);
                                $('#hdnProdSubGrpId' + row).val(itm.ProductSubGroupId);
                                $('#hdnItemCode' + row).val(itm.ItemCode);

                                $('.chkEdit').prop("checked", false);
                                $('.btnEdit').click();
                            });
                            if (items.length < 14) {
                                length = 14 - items.length;
                            }
                            for (var i = 0; i < length; i++) {
                                AddMoreRow();
                            }
                        }
                        else {
                            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
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

                $('.gvDiscountHistory tbody').empty();
                $.ajax({
                    url: 'DiscountTypeIncExcMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    // data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','OptionId': '" + $('.ddlOption').val() + "','DiscountType': '" + $('.ddlDiscountType').val() + "'}",
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
                            $('.divDiscountReport').removeAttr('style');
                            if (ReportData[0].OptionId == 1) {
                                // $('#gvDiscountHistory').find('th:nth-child(5)').hide();
                                $('.tdSS').hide();
                                $('.thss').hide();
                                $('.thCustomer').show();
                                $('.tdCustomer').show();
                                $('.tdSTOD').hide();

                                $('.thQPS').hide();
                                $('.tdQPS').show();
                                $('.thMachine').hide();
                                $('.tdMachine').show();
                                $('.thParlour').hide();
                                $('.tdParlour').show();
                                $('.thFOW').hide();
                                $('.tdFOW').show();
                                $('.thSecFright').hide();
                                $('.tdSecFrieght').show();
                                $('.thVRS').hide();
                                $('.tdVRS').show();
                                $('.thRateDiff').hide();
                                $('.tdRateDiff').show();
                                $('.thIOU').hide();
                                $('.tdIOU').show();

                            }
                            else if (ReportData[0].OptionId == 2) {
                                //  $('#gvDiscountHistory').find('th:nth-child(4)').hide();
                                $('.thCustomer').hide();
                                $('.tdCustomer').hide();
                                $('.tdSS').show();
                                $('.thss').show();
                                $('.tdSTOD').show();

                                $('.thQPS').hide();
                                $('.tdQPS').hide();
                                $('.thMachine').hide();
                                $('.tdMachine').hide();
                                $('.thParlour').hide();
                                $('.tdParlour').hide();
                                $('.thFOW').hide();
                                $('.tdFOW').hide();
                                $('.thSecFright').hide();
                                $('.tdSecFrieght').hide();
                                $('.thVRS').hide();
                                $('.tdVRS').hide();
                                $('.thRateDiff').hide();
                                $('.tdRateDiff').hide();
                                $('.thIOU').hide();
                                $('.tdIOU').hide();
                            }
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td >" + ReportData[i].EmpName + "</td>"
                                          + "<td class='tdRegion'>" + ReportData[i].Region + "</td>"
                                        + "<td class='tdSS'>" + ReportData[i].SSName + "</td>"
                                        + "<td class='tdDist'>" + ReportData[i].Distributor + "</td>"
                                        + "<td>" + ReportData[i].CustGroupName + "</td>"
                                        + "<td class='tdCustomer'>" + ReportData[i].CustomerName + "</td>"
                                        + "<td>" + ReportData[i].DivisionName + "</td>"
                                        + "<td>" + ReportData[i].ItemGroupName + "</td>"
                                        + "<td>" + ReportData[i].ItemSubGroupName + "</td>"
                                        + "<td>" + ReportData[i].ItemName + "</td>"
                                        + "<td class='tdMaster'>" + ReportData[i].MasterSchm + "</td>"
                                        + "<td class='tdQPS'>" + ReportData[i].QPS + "</td>"
                                        + "<td class='tdMachine'>" + ReportData[i].Machine + "</td>"
                                        + "<td class='tdParlour'>" + ReportData[i].Parlour + "</td>"
                                        + "<td class='tdFOW'>" + ReportData[i].FOW + "</td>"
                                        + "<td class='tdSecFrieght'>" + ReportData[i].SecFright + "</td>"
                                        + "<td class='tdVRS'>" + ReportData[i].VRS + "</td>"
                                        + "<td class='tdRateDiff'>" + ReportData[i].RateDiff + "</td>"
                                        + "<td class='tdIOU'>" + ReportData[i].IOU + "</td>"
                                        + "<td class='tdSTOD'>" + ReportData[i].STOD + "</td>"
                                        + "<td>" + ReportData[i].FromDate + "</td>"
                                        + "<td>" + ReportData[i].ToDate + "</td>"
                                        + "<td>" + ReportData[i].IsInclude + "</td>"
                                        + "<td>" + ReportData[i].IsActive + "</td>"
                                        + "<td>" + ReportData[i].IsDeleted + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"

                                $('.gvDiscountHistory > tbody').append(str);


                                if (ReportData[0].OptionId == 1) {
                                    $('.tdDist').show();
                                    $('.tdSS').hide();
                                    $('.tdSTOD').hide();
                                    // $('.tdRegion').show();
                                    $('.thQPS').show();
                                    $('.tdQPS').show();
                                    $('.thMachine').show();
                                    $('.tdMachine').show();
                                    $('.thParlour').show();
                                    $('.tdParlour').show();
                                    $('.thFOW').hide();
                                    $('.tdFOW').hide();
                                    $('.thSecFright').hide();
                                    $('.tdSecFrieght').hide();
                                    $('.thVRS').hide();
                                    $('.tdVRS').hide();
                                    $('.thRateDiff').hide();
                                    $('.tdRateDiff').hide();
                                    $('.thIOU').hide();
                                    $('.tdIOU').hide();
                                }
                                else if (ReportData[0].OptionId == 2) {
                                    $('.tdDist').hide();
                                    $('.tdSS').show();
                                    // $('.tdRegion').show();

                                    $('.tdQPS').hide();
                                      $('.thMachine').hide();
                                    $('.tdMachine').hide();
                                     $('.thParlour').hide();
                                    $('.tdParlour').hide();
                                     $('.thFOW').hide();
                                    $('.tdFOW').hide();
                                     $('.thSecFright').hide();
                                    $('.tdSecFrieght').hide();
                                     $('.thVRS').hide();
                                    $('.tdVRS').hide();
                                      $('.thRateDiff').hide();
                                    $('.tdRateDiff').hide();
                                     $('.thIOU').hide();
                                    $('.tdIOU').hide();
                                }
                                else {
                                    // $('.tdRegion').hide();
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

                if ($('.gvDiscountHistory tbody tr').length > 0) {

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
                    aryJSONColTable.push({ "width": "15px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "5px", "aTargets": 5 });//"sClass": "dtbodyLeft",
                    aryJSONColTable.push({ "width": "7px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "10px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "10px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "15px", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "15px", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "15px", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "15px", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 23 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 24 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 25 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 26 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 27 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 28 });
                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 29 });


                    $('.gvDiscountHistory').DataTable({
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
                                //data += 'Discount Type,' + $('.ddlDiscountType option:selected').text() + '\n';
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

                                sheet = ExportXLS(xlsx, 5);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                //  var r2 = Addrow(3, [{ key: 'A', value: 'Discount Type' }, { key: 'B', value: $('.ddlDiscountType option:selected').text() }]);
                                var r3 = Addrow(3, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                var r4 = Addrow(4, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r5 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //portrait
                            pageSize: 'A3', //A3 , A5 , A6 , legal , letter
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
                                                    // { text: 'Discount Type : ' + $('.ddlDiscountType option:selected').text() + "\n" },
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
                                for (i = 1; i < rowCount; i++) { // rows alignment setting by default left

                                    if (option == 1) {
                                        doc.content[0].table.body[i][0].alignment = 'center';
                                        doc.content[0].table.body[i][1].alignment = 'left';
                                        doc.content[0].table.body[i][2].alignment = 'left';
                                        doc.content[0].table.body[i][3].alignment = 'left';
                                        doc.content[0].table.body[i][4].alignment = 'left';
                                        doc.content[0].table.body[i][5].alignment = 'left';
                                        doc.content[0].table.body[i][6].alignment = 'left';
                                        doc.content[0].table.body[i][7].alignment = 'left';
                                        doc.content[0].table.body[i][8].alignment = 'left';
                                        doc.content[0].table.body[i][9].alignment = 'left';
                                        doc.content[0].table.body[i][10].alignment = 'left';
                                        doc.content[0].table.body[i][11].alignment = 'left';
                                        doc.content[0].table.body[i][12].alignment = 'left';
                                        doc.content[0].table.body[i][13].alignment = 'left';
                                        doc.content[0].table.body[i][14].alignment = 'left';
                                        doc.content[0].table.body[i][15].alignment = 'left';
                                        doc.content[0].table.body[i][16].alignment = 'left';
                                        doc.content[0].table.body[i][17].alignment = 'left';
                                        doc.content[0].table.body[i][18].alignment = 'left';
                                        doc.content[0].table.body[i][19].alignment = 'left';
                                        doc.content[0].table.body[i][20].alignment = 'center';
                                        doc.content[0].table.body[i][21].alignment = 'left';
                                        doc.content[0].table.body[i][22].alignment = 'center';
                                        //doc.content[0].table.body[i][23].alignment = 'left';
                                        //doc.content[0].table.body[i][24].alignment = 'left';
                                        //doc.content[0].table.body[i][25].alignment = 'center';
                                        //doc.content[0].table.body[i][26].alignment = 'left';
                                        //doc.content[0].table.body[i][27].alignment = 'center';

                                    }
                                    else {
                                        doc.content[0].table.body[i][0].alignment = 'center';
                                        doc.content[0].table.body[i][1].alignment = 'left';
                                        doc.content[0].table.body[i][2].alignment = 'left';
                                        doc.content[0].table.body[i][3].alignment = 'left';
                                        doc.content[0].table.body[i][4].alignment = 'left';
                                        doc.content[0].table.body[i][5].alignment = 'left';
                                        doc.content[0].table.body[i][6].alignment = 'left';
                                        doc.content[0].table.body[i][7].alignment = 'left';
                                        doc.content[0].table.body[i][8].alignment = 'left';
                                        doc.content[0].table.body[i][9].alignment = 'left';
                                        doc.content[0].table.body[i][10].alignment = 'left';
                                        doc.content[0].table.body[i][11].alignment = 'left';
                                        doc.content[0].table.body[i][12].alignment = 'left';
                                        doc.content[0].table.body[i][13].alignment = 'center';
                                        doc.content[0].table.body[i][14].alignment = 'left';
                                        doc.content[0].table.body[i][15].alignment = 'center';
                                        //doc.content[0].table.body[i][16].alignment = 'left';
                                        //doc.content[0].table.body[i][17].alignment = 'left';
                                        //doc.content[0].table.body[i][18].alignment = 'center';
                                        //doc.content[0].table.body[i][19].alignment = 'left';
                                        //doc.content[0].table.body[i][20].alignment = 'center';

                                    }
                                    // doc.content[0].table.body[i][28].alignment = 'center';
                                    //  doc.content[0].table.body[i][29].alignment = 'center';
                                    //  doc.content[0].table.body[i][20].alignment = 'center';
                                };
                                if (option == 1) {
                                    doc.content[0].table.body[0][0].alignment = 'center';
                                    doc.content[0].table.body[0][1].alignment = 'left';
                                    doc.content[0].table.body[0][2].alignment = 'left';
                                    doc.content[0].table.body[0][3].alignment = 'left';
                                    doc.content[0].table.body[0][4].alignment = 'left';
                                    doc.content[0].table.body[0][5].alignment = 'left';
                                    doc.content[0].table.body[0][6].alignment = 'left';
                                    doc.content[0].table.body[0][7].alignment = 'left';
                                    doc.content[0].table.body[0][8].alignment = 'left';
                                    doc.content[0].table.body[0][9].alignment = 'left';
                                    doc.content[0].table.body[0][10].alignment = 'left';
                                    doc.content[0].table.body[0][11].alignment = 'left';
                                    doc.content[0].table.body[0][12].alignment = 'left';
                                    doc.content[0].table.body[0][13].alignment = 'left';
                                    doc.content[0].table.body[0][14].alignment = 'left';
                                    doc.content[0].table.body[0][15].alignment = 'left';
                                    doc.content[0].table.body[0][16].alignment = 'left';
                                    doc.content[0].table.body[0][17].alignment = 'left';
                                    doc.content[0].table.body[0][18].alignment = 'left';
                                    doc.content[0].table.body[0][19].alignment = 'left';
                                    doc.content[0].table.body[0][20].alignment = 'center';
                                    doc.content[0].table.body[0][21].alignment = 'left';
                                    doc.content[0].table.body[0][22].alignment = 'center';
                                    //doc.content[0].table.body[0][23].alignment = 'left';
                                    //doc.content[0].table.body[0][24].alignment = 'left';
                                    //doc.content[0].table.body[0][25].alignment = 'center';
                                    //doc.content[0].table.body[0][26].alignment = 'left';
                                    //doc.content[0].table.body[0][27].alignment = 'center';
                                    //    doc.content[0].table.body[0][28].alignment = 'center';
                                    //   doc.content[0].table.body[0][29].alignment = 'center';
                                }
                                else {
                                    doc.content[0].table.body[0][0].alignment = 'center';
                                    doc.content[0].table.body[0][1].alignment = 'left';
                                    doc.content[0].table.body[0][2].alignment = 'left';
                                    doc.content[0].table.body[0][3].alignment = 'left';
                                    doc.content[0].table.body[0][4].alignment = 'left';
                                    doc.content[0].table.body[0][5].alignment = 'left';
                                    doc.content[0].table.body[0][6].alignment = 'left';
                                    doc.content[0].table.body[0][7].alignment = 'left';
                                    doc.content[0].table.body[0][8].alignment = 'left';
                                    doc.content[0].table.body[0][9].alignment = 'left';
                                    doc.content[0].table.body[0][10].alignment = 'left';
                                    doc.content[0].table.body[0][11].alignment = 'left';
                                    doc.content[0].table.body[0][12].alignment = 'left';
                                    doc.content[0].table.body[0][13].alignment = 'center';
                                    doc.content[0].table.body[0][14].alignment = 'left';
                                    doc.content[0].table.body[0][15].alignment = 'center';
                                    //doc.content[0].table.body[0][16].alignment = 'left';
                                    //doc.content[0].table.body[0][17].alignment = 'left';
                                    //doc.content[0].table.body[0][18].alignment = 'center';
                                    //doc.content[0].table.body[0][19].alignment = 'left';
                                    //doc.content[0].table.body[0][20].alignment = 'center';
                                }
                            }
                        }]
                    });
                }
            }
        }

        function ClearControls() {
            $('.divDiscountEntry').attr('style', 'display:none;');
            $('.divDiscountReport').attr('style', 'display:none;');


            $('.divMissData').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblDiscountExc tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvDiscountHistory')) {
                $('.gvDiscountHistory').DataTable().destroy();
            }

            $('.gvDiscountHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                // $('.divDiscountReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');

                var option = $(".ddlOption").val();
                if (option == 1) {
                    $('.tdSS').hide();
                    $('.thss').hide();
                    $('.tdSTOD').hide();
                    $('.thSTOD').hide();
                    $('.tdCustomer').show();
                    $('.thCustomer').show();
                }
                else if (option == 2) {
                    $('.tdSS').show();
                    $('.thss').show();
                    $('.tdCustomer').hide();
                    $('.thCustomer').hide();
                    $('.tdSTOD').show();
                    $('.thSTOD').show();
                }
            }
            else {
                $('.divDiscountEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');
                //  $('.chkIsHistory').find('input').not(':checked');
                $('.chkIsHistory').find('input').prop('checked', false);
                //$('#myCheckbox').prop('checked', false);
                $('#CountRowClaim').val(0);
                FillData();
                AddMoreRow();
            }

        }

        function RemoveClaimLockingRow(row) {

            var DiscountExcId = $('table#tblDiscountExc tr#trClaim' + row).find(".hdnDiscountExcId").val();
            $('table#tblDiscountExc tr#trClaim' + row).find(".IsChange").val("1");
            $('table#tblDiscountExc tr#trClaim' + row).remove();
            $('table#tblDiscountExc tr#trClaim' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = DiscountExcId + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblDiscountExc tr#trClaim' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }

        function Cancel() {
            window.location = "../Master/DiscountTypeIncExcMaster.aspx";
        }


        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowClaim').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
            CheckDateValidation(row);
        }
        function CheckDateValidation(row) {
            var rowCnt_FSSI = 1;
            var cnt = 0;
            var errRow = 0;

            var NewFromDate = $("#tdFromDate" + row).val();
            var NewToDate = $("#tdToDate" + row).val();
            $('#tblDiscountExc  > tbody > tr').each(function (row1, tr) {
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
                        $("#tdToDate" + LineNum).val('');
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
            $('#tblDiscountExc  > tbody > tr').each(function (row, tr) {
                //  var Days = $("input[name='days']", this).val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                if (IsChange == "1") {
                    //if (Days == "" || Days == 0) {
                    //    ModelMsg("Please enter days", 3);
                    //    $.unblockUI();
                    //    IsValid = false;
                    //    return false;
                    //}
                }
            });
            if (!IsValid) {
                $.unblockUI();
                return false;
            }
            $('#tblDiscountExc  > tbody > tr').each(function (row, tr) {
                var RegionName = $("input[name='AutoRegion']", this).val().split('-').pop().trim();//$("input[name='AutoRegion']", this).val();
                var EmpName = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();// $("input[name='AutoEmpName']", this).val();
                var DistName = $("input[name='AutoDistName']", this).val().split('-').pop().trim();
                var SSName = $("input[name='AutoSSName']", this).val().split('-').pop().trim();
                //   var Days = $("input[name='days']", this).val();
                //var EmpID = $("input[name='AutoEmpName']", this).val().split('#').pop().trim();

                var CustGroup = $("input[name='AutoCustGroup']", this).val().split('#').pop().trim();
                var Customer = $("input[name='AutoCustomer']", this).val().split('-').pop().trim();
                var Division = $("input[name='AutoDivision']", this).val().split('#').pop().trim();
                var ProdGrp = $("input[name='AutoProdGrp']", this).val().split('#').pop().trim();
                var ProdSubGrp = $("input[name='AutoProdSubGrp']", this).val().split('#').pop().trim();
                var ItemCode = $("input[name='AutoItemCode']", this).val().split('#').pop().trim();


                var RgnId = $("input[name='hdnRegionId']", this).val().trim();
                var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                var DistId = $("input[name='hdnDistId']", this).val().trim();
                var SSId = $("input[name='hdnSSId']", this).val().trim();
                var IsDeleted = $('#hdnIsRowDeleted').val();
                var IsChange = $("input[name='IsChange']", this).val().trim();

                var FromDate = $("input[name='tdFromDate']", this).val();
                var ToDate = $("input[name='tdToDate']", this).val();


                if ((RegionName != "" || EmpName != "" || DistName != '' || SSName != '' || CustGroup != '' || Customer != '' || FromDate != '' || ToDate != '') && (IsChange == "1" || IsDeleted == 1)) {
                    if (Division == '' && ProdGrp == '' && ProdSubGrp == '' && ItemCode == '') {
                        totalItemcnt = 0;
                        $.unblockUI();
                        ModelMsg('Please select proper division,proudct group, product sub group or item  at row' + (row + 1), 3);
                        return false;
                    }
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
                    var DiscountExcId = $("input[name='hdnDiscountExcId']", this).val().trim();
                    var RgnId = $("input[name='hdnRegionId']", this).val().trim();
                    var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                    var DistId = $("input[name='hdnDistId']", this).val().trim();
                    var SSId = $("input[name='hdnSSId']", this).val().trim();
                    // var DaysId = $("input[name='hdnDaysId']", this).val().trim();


                    var IsMaster = $("input[name='chkMaster']", this).is(':checked');
                    var IsQPS = $("input[name='chkQPS']", this).is(':checked');
                    var IsMachine = $("input[name='chkMachine']", this).is(':checked');
                    var IsParlour = $("input[name='chkParlour']", this).is(':checked');
                    var IsFOW = $("input[name='chkFOW']", this).is(':checked');
                    var IsSecFri = $("input[name='chkSecFrieght']", this).is(':checked');
                    var IsVRS = $("input[name='chkVRS']", this).is(':checked');
                    var IsRateDiff = $("input[name='chkRateDiff']", this).is(':checked');
                    var IsIOU = $("input[name='chkIOU']", this).is(':checked');
                    var IsSTD = $("input[name='chkSTOD']", this).is(':checked');

                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var IsInclude = $("input[name='chkInclude']", this).is(':checked');
                    var IPAddress = $("#hdnIPAdd").val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();

                    var CustGroupId = $("input[name='hdnCustGroupId']", this).val().trim();
                    var CustId = $("input[name='hdnCustomerId']", this).val().trim();
                    var DivisionId = $("input[name='hdnDivisionId']", this).val().trim();
                    var ProdGrpId = $("input[name='hdnProdGrpId']", this).val().trim();
                    var ProdSubGrpId = $("input[name='hdnProdSubGrpId']", this).val().trim();
                    var ItemCode = $("input[name='hdnItemCode']", this).val().trim();



                    var obj = {
                        DiscountExcId: DiscountExcId,
                        RegionId: RegionName,
                        EmpId: EmpName,
                        DistId: DistId,
                        SSId: SSId,
                        IsActive: IsActive,
                        IPAddress: IPAddress,
                        IsChange: IsChange,
                        CustGroupId: CustGroupId,
                        CustId: CustId,
                        DivisionId: DivisionId,
                        ProdGrpId: ProdGrpId,
                        ProdSubGrpId: ProdSubGrpId,
                        ItemCode: ItemCode,
                        IsInclude: IsInclude,
                        FromDate: FromDate,
                        ToDate: ToDate,
                        Master: IsMaster,
                        QPS: IsQPS,
                        Machine: IsMachine,
                        Parlour: IsParlour,
                        FOW: IsFOW,
                        SecFright: IsSecFri,
                        VRS: IsVRS,
                        RateDiff: IsRateDiff,
                        IOU: IsIOU,
                        SToD: IsSTD
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
                    url: 'DiscountTypeIncExcMaster.aspx/SaveData',
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
        function downloadMapping() {
            window.open("../Document/CSV Formats/DealertemIncExclude.csv");
        }
    </script>
    <style>
        table.dataTable tbody th, table.dataTable tbody td {
            padding: 2px 5px !important;
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
        /*ul.ui-autocomplete { top: 217.125px !important;
            z-index: 100000000;
            position: absolute;
        }*/
        /*body {
            overflow:hidden;
        }*/
        table#tblDiscountExc.dataTable tbody th {
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

        table.dataTable tbody th {
            text-align: left;
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



        table.gvDiscountHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        /*.dataTables_scrollHeadInner {
            width: auto !important;
        }*/

        /*table.gvDiscountHistory td:nth-child(1), table.gvDiscountHistory td:nth-child(4), table.gvDiscountHistory td:nth-child(5) {
            text-align: left;
        }

        table.gvDiscountHistory td:nth-child(6), table.gvDiscountHistory td:nth-child(7) {
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
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="1" onchange="ShowDistOrSSOnChange();">
                            <asp:ListItem Value="2">Distributor To Dealer</asp:ListItem>
                            <asp:ListItem Value="4">SS To Distributor</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <%--<div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Discount Type</label>
                        <asp:DropDownList runat="server" ID="ddlDiscountType" CssClass="ddlDiscountType form-control" TabIndex="1" onchange="ShowDistOrSSOnChange();">
                            <asp:ListItem Text="Master" Value="M" Selected="True" />
                            <asp:ListItem Text="QPS" Value="S" />
                            <asp:ListItem Text="Machine Discount" Value="D" />
                            <asp:ListItem Text="Parlour Discount" Value="P" />
                            <asp:ListItem Text="FOW Electricity Claim" Value="F" />
                            <asp:ListItem Text="Secondary Freight Transportation" Value="T" />
                            <asp:ListItem Text="VRS Discount" Value="V" />
                            <asp:ListItem Text="Rate Difference" Value="R" />
                            <asp:ListItem Text="IOU Claim" Value="I" />
                            <asp:ListItem Text="S TO D" Value="A" />
                        </asp:DropDownList>
                    </div>
                </div>--%>
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
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload File" ID="Label3" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flpLineItemExcInc" TabIndex="1" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnMappingUpload" runat="server" TabIndex="2" Text="Upload File" OnClick="btnMappingUpload_Click" CssClass="btn btn-primary" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Button ID="btnMappingDwnload" runat="server" TabIndex="3" Text="Download Format" CssClass="btn btn-primary" OnClientClick="downloadMapping(); return false;" />
                    </div>
                </div>
            </div>
            <input type="hidden" id="CountRowClaim" />
            <div id="divDiscountEntry" class="divDiscountEntry" runat="server" style="max-height: 80vh; position: absolute;">
                <table id="tblDiscountExc" class="table table-bordered nowrap" border="1" tabindex="8" style="border-collapse: collapse; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 2%; text-align: center;">Sr</th>
                            <th style="text-align: center;">Edit</th>
                            <th style="width: 3.5%; text-align: center;">Delete</th>
                            <th style="width: 15%; text-align: left  !important; padding-left: 10px !important;">Employee</th>
                            <th style="width: 15%; text-align: left !important; padding-left: 10px !important;">Region</th>
                            <th style="width: 15%; padding-left: 10px !important;" class="thSS">Super Stockist</th>
                            <th style="width: 15%; padding-left: 10px !important;">Distributor</th>
                            <th style="width: 15%; padding-left: 10px !important;">Customer Group</th>
                            <th style="width: 12%; padding-left: 10px !important;" class="thCustomer">Customer</th>
                            <th style="width: 12%; padding-left: 10px !important;">Division</th>
                            <th style="width: 12%; padding-left: 10px !important;">Product Group</th>
                            <th style="width: 12%; padding-left: 10px !important;">Product Sub-Group</th>
                            <th style="width: 12%; padding-left: 10px !important;">Item-Code</th>

                            <th style="width: 3%; padding-left: 3px !important;" class="thMaster">Master</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thQPS">QPS</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thMachine">Machine</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thParlour">Parlour</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thFOW">FOW</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thSecFright">Sec. Frig.</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thVRS">VRS</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thRateDiff">Rate Diff.</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thIOU">IOU</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thSTOD">STOD</th>

                            <th style="width: 10%;">From-Date</th>
                            <th style="width: 10%;">To-Date</th>
                            <th style="width: 5%; text-align: left  !important; padding-left: 3px !important;">Inc/Exc</th>
                            <th style="width: 4%; padding-left: 3px !important;">Active</th>
                            <%--<th style="width: 3%;">Unique-No</th>--%>
                            <th style="width: 7%; padding-left: 5px !important;">Entry By</th>
                            <th style="width: 5%;">Entry Date/Time</th>
                            <th style="width: 7%; padding-left: 5px !important;">Updated By</th>
                            <th style="width: 5%;">Update Date/Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divDiscountReport" class="divDiscountReport" style="max-height: 30vh; overflow-y: auto;">
                <table id="gvDiscountHistory" class="gvDiscountHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="text-align: center; width: 2%;">Sr</th>
                            <th style="width: 10%; padding-left: 5px !important;">Employee</th>
                            <th style="width: 10%; padding-left: 5px !important;" class="thRegion">Region</th>
                            <th style="width: 10%; padding-left: 5px !important;" class="thss">Super Stockist</th>
                            <th style="width: 10%; padding-left: 5px !important;" class="thDist">Distritutor</th>
                            <th style="width: 9%; padding-left: 5px !important;">Customer Group</th>
                            <th style="width: 4%; padding-left: 5px !important;" class="thCustomer">Customer</th>
                            <th style="width: 4%; padding-left: 5px !important;">Division</th>
                            <th style="width: 4%; padding-left: 5px !important;">Product Group</th>
                            <th style="width: 4%; padding-left: 5px !important;">Product Sub-Group</th>
                            <th style="width: 4%; padding-left: 5px !important;">Item-Code</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thMaster">Master</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thQPS">QPS</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thMachine">Machine</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thParlour">Parlour</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thFOW">FOW</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thSecFright">Sec. Freight</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thVRS">VRS</th>
                            <th style="width: 4%; padding-left: 3px !important;" class="thRateDiff">Rate Diff.</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thIOU">IOU</th>
                            <th style="width: 3%; padding-left: 3px !important;" class="thSTOD">STOD</th>
                            <th style="width: 3%;">From-Date</th>
                            <th style="width: 3%;">To-Date</th>
                            <th style="width: 3%; padding-left: 5px !important;">Inc/Exc</th>
                            <th style="width: 3%; padding-left: 5px !important;">Active</th>
                            <%--<th style="width: 2%;">Uniq No</th>--%>
                            <th style="width: 2%; padding-left: 5px !important;">Deleted</th>
                            <th style="width: 5%; padding-left: 5px !important;">Entry By</th>
                            <th style="width: 5%;">Entry Date/Time</th>
                            <th style="width: 5%; padding-left: 5px !important;">Update By</th>
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

