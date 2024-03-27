<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="WhatsAppBusinessConfiguation.aspx.cs" Inherits="Master_WhatsAppBusinessConfiguation" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">

        function ClearAllTextboxConfig() {
            if ($(".txtRegionName").length > 0) {
                $(".txtEmpCust").val('');
                $(".txtSSCodeName").val('');
                $(".txtDistri").val('');
                $(".txtDealerName").val('');
            }
        }
        function ClearAllTextOnEmployeeConfig() {
            if ($(".txtEmpCust").length > 0) {
                $(".txtSSCodeName").val('');
                $(".txtDistri").val('');
                $(".txtDealerName").val('');
            }
        }
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            load();
            // ChangePeriod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            load();
        }
        function load() {
            $(".gvScheduleData").tableHeadFixer('40vh');
            //   ChangePeriod();
            AppliForChange();
            $('.dataTables_scrollBody').on('scroll', function () {
                if ($('.dataTables_scrollBody').scrollTop() != 0)
                    $.cookie("ScrollLastPos", $('.dataTables_scrollBody').scrollTop());
            });
            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("WhatsappConfig", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("WhatsappConfig") + '"]').tab('show');

        }
        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtSSCodeName').is(":visible") ? $('.txtSSCodeName').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            $('.txtDealerName').val("");
            var EmpID = $('.txtEmpCust').is(":visible") ? $('.txtEmpCust').val().split('-').pop() : "0";
            var reg = $('.txtRegionName').is(":visible") ? $('.txtRegionName').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-0-0-" + EmpID);
        }
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpCust').is(":visible") ? $('.txtEmpCust').val().split('-').pop() : "0";
            var reg = $('.txtRegionName').is(":visible") ? $('.txtRegionName').val().split('-').pop() : "0";
            var dist = $('.txtDistri').is(":visible") ? $('.txtDistri').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + "0" + "-" + "0" + "-" + dist + "-" + EmpID);
        }
        function acettxtEmpCode_OnClientPopulating(sender, args) {
            var EmpGroupID = $('.txtEmpGroupId').is(":visible") ? $('.txtEmpGroupId').val().split("#").pop() : "0";
            sender.set_contextKey(EmpGroupID == "" ? null : "0-" + EmpGroupID);
        }
        function txtEmpGroup_OnClientPopulating(sender, args) {
            $('.txtEmployeeCode').val("");
        }

        function acettxtEmpCustCode_OnClientPopulating(sender, args) {
            $('.txtDistri').val("");
            $('.txtDealerName').val("");
            var reg = $('.txtRegionName').is(":visible") ? $('.txtRegionName').val().split('-').pop() : "0";
            var EmpType = $('.ddlMessageForType').val();
            sender.set_contextKey(EmpType == "" ? null : "0-" + reg + "-" + EmpType);
        }
        function onAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }

        var AvailableMessage = [];
        var CustGroupID = 0, EmpGroupID = 0;
        var MaxLengthMsgBody = 500;

        $(document).ready(function () {
            for (var i = 0; i <= 31; i++) {
                $(".ddlDay1").append($("<option></option>").val(i).html(i));
                $(".ddlDay2").append($("<option></option>").val(i).html(i));
                $(".ddlDay3").append($("<option></option>").val(i).html(i));
            }
            $('#CountRowMaterial').val(0);
            AppliForChange();
            MessagePeriodChange();
            $("#tblConfig").tableHeadFixer('34vh');
            $('.txtMessageBody').keypress(function (e) {
                if ($(this).val().length >= MaxLengthMsgBody) {
                    e.preventDefault();
                }
            });

            $('.txtEmpGroup').autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'WhatsAppBusinessConfiguation.aspx/SearchEmployeeGroup',
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
                    //   $('#AutoEmpGroup' + ind).val(ui.item.value + " ");
                    //$('#hdnEmpId').val(ui.item.id);
                    $('.txtEmpGroup').val("");
                    $('.txtEmpCode').val("");
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('.txtEmpGroup').val("");

                        //$('#hdnEmpId').val(0);
                    }
                },
                minLength: 1
            });
            $('.txtEmpGroup').on('autocompleteselect', function (e, ui) {
                $('.txtEmpGroup').val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('.txtEmpGroup').on('change keyup', function () {
                if ($('.txtEmpGroup').val() == "") {
                    //$('#hdnEmpId').val('0');
                    //ClearCustomerRow(ind);
                }
            });

            $('.txtEmpGroup').on('blur', function (e, ui) {
                if ($('.txtEmpGroup').val().trim() != "") {
                    if ($('.txtEmpGroup').val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee Group", 3);
                        $('.txtEmpGroup').val("");
                        //$('#hdnEmpId').val('0');
                        return;
                    }
                    var txt = $('.txtEmpGroup').val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;

                    //CheckDuplicateCustomer($('#AutoEmpGroup' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoCustName' + ind).val().trim(), ind, 2);
                }
            });


            $('.txtEmpCode').autocomplete({
                source: function (request, response) {
                    var EmpGroupId = $('.txtEmpGroup').val() != "" && $('.txtEmpGroup').val() != undefined ? $('.txtEmpGroup').val().split("#")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'WhatsAppBusinessConfiguation.aspx/SearchEmployee',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpGroupId':'" + EmpGroupId + "'}",
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
                    //   $('#AutoEmpGroup' + ind).val(ui.item.value + " ");
                    //$('#hdnEmpId').val(ui.item.id);
                    $('.txtEmpCode').val("");
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('.txtEmpCode').val("");
                        //$('#hdnEmpId').val(0);
                    }
                },
                minLength: 1
            });
            $('.txtEmpCode').on('autocompleteselect', function (e, ui) {
                $('.txtEmpCode').val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('.txtEmpCode').on('change keyup', function () {
                if ($('.txtEmpCode').val() == "") {
                    //$('#hdnEmpId').val('0');
                    //ClearCustomerRow(ind);
                }
            });

            $('.txtEmpCode').on('blur', function (e, ui) {
                if ($('.txtEmpCode').val().trim() != "") {
                    if ($('.txtEmpCode').val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Employee", 3);
                        $('.txtEmpCode').val("");
                        //$('#hdnEmpId').val('0');
                        return;
                    }
                    var txt = $('.txtEmpCode').val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;

                    //CheckDuplicateCustomer($('#AutoEmpGroup' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoCustName' + ind).val().trim(), ind, 2);
                }
            });
            $('.txtCustGroup').focusout(function () {

                if ($('.txtCustGroup').val().length > 0) {

                    var sv = $.ajax({
                        url: 'WhatsAppBusinessConfiguation.aspx/GetCustGroupID',
                        type: 'POST',
                        async: false,
                        traditional: true,
                        dataType: 'json',
                        data: JSON.stringify({ CustGroupName: $('.txtCustGroup').val().split("#")[0].trim() }),
                        contentType: 'application/json; charset=utf-8'
                    })

                    sv.success(function (result) {
                        if (result.d == "" || result.d == "0") {
                            ModelMsg('Cust Group Detail Not found. Pease re-select customer group.', 3);
                            $('.txtCustGroup').val('');
                            return false;
                        }
                        else {
                            CustGroupID = result.d;
                        }
                    });

                    sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                        ModelMsg('Cust Group Detail Not found. Pease select proper customer group.' + XMLHttpRequest.responseText, 3)
                        return false;
                    });
                }
            });


            $('.fromdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //minDate: '0',
            });

            $('.todate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //minDate: '0'
            });

            $('.fromdate').change(function () {
                startDate = $(this).datepicker('getDate');
                $('.todate').datepicker("option", "minDate", startDate);
            })

            ///////
            $('.todate').change(function () {
                endDate = $(this).datepicker('getDate');
                $('.fromdate').datepicker("option", "maxDate", endDate);

            })

            //$(".todate").focusout(function () {
            //    $(".hasDatepicker").on("blur", function (e) { $(this).off("focus").datepicker("hide"); });
            //});
        });

        function autoCompleteMessageCode_OnClientPopulating(sender, args) {
            var key = $('.ddlAppliFor option:selected').val();
            sender.set_contextKey(key);
        }


        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegionName').is(":visible") ? $('.txtRegionName').val().split('-').pop() : "0";
            var EmpID = $('.txtEmpCust').is(":visible") ? $('.txtEmpCust').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-0-" + EmpID);
        }

        //function autoCompleteDistriCode_OnClientPopulating(sender, args) {
        //    var reg = $('.txtRegionName').val().split('-').pop();
        //    //  var ss = $('.txtSSCodeName').val().split('-').pop();
        //    sender.set_contextKey(reg + "-0-0-" + "0" + "-" + 0);
        //}
        //function GetSelectedID() {
        //    var messageCode = $('.txtMessageCode').val().split('-')[3];
        //    // var messageCode = $('.txtMessageCode').val();
        //    GetMessageDetailByID(messageCode.trim());
        //}
        function onAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }
        function RemoveMaterialRow(row) {
            $('#trMaterial' + row).remove();
        }

        function ClearConfigControls() {

            CustGroupID = 0;
            EmpGroupID = 0;
            $('.txtDistRegion').val('');
            $('.txtEmpGroup').val('');
            $('.txtEmpCode').val('');
            $('.txtSSCode').val('');
            $('.txtDistCode').val('');
            $('.txtCustGroup').val('');
            $('.txtDealerCode').val('');
            $('.txtHrEmpCode').val('');
            // $('.chkIsInclude > input[type=checkbox]').prop('checked', true);
        }

        function ClearAllInputs() {

            $('.hidJsonInputHeader').val('');
            $('.hidJsonInputMaterial').val('');
            $('.txtMessageCode').removeAttr("disabled");
            $('.txtMessageCode').val('');
            $('.txtSubject').val('');
            // $('.fromdate').val('');
            // $('.todate').val('');
            $('.txtMessageBody').val('');
            $('.messageimg').css('display', 'none');
            $('.messageimg').attr('src', '#');

            $('.txtDistRegion').val('');
            $('.txtEmpGroup').val('');
            $('.txtEmpCode').val('');
            $('.txtSSCode').val('');
            $('.txtDistCode').val('');
            $('.txtCustGroup').val('');
            $('.txtHrEmpCode').val('');
            //   $('.chkIsInclude > input[type=checkbox]').prop('checked', true);
            $('#tblConfig tbody').empty();
            $('#CountRowMaterial').val(0);
            // $('.chkActive > input[type=checkbox]').prop('checked', true);
            if ($('.chkMode').is(':checked') == true) {
                $('.txtMessageCode').val("Auto Generated");
                $('.txtMessageCode').attr("disabled", "disabled");
                // $('.ddlAppliFor').removeAttr("disabled");
                $('.txtMessageCode').removeAttr("style");
            }
            else {
                $('.txtMessageCode').removeAttr("disabled");
                // $('.ddlAppliFor').attr("disabled", "disabled");
                $('.txtMessageCode').css('background-color', '#FAFFBD');
            }

            $('.txtCreatedBy').val("");
            $('.txtCreatedTime').val("");
            $('.txtUpdatedBy').val("");
            $('.txtUpdatedTime').val("");
        }
        function MessagePeriodChange() {
            ClearAllInputs();
            ClearConfigControls();
            $('#tblConfig tbody').empty();
            $('#CountRowMaterial').val(0);
            // $('.divCustomer').attr('style', 'display:none');
            //$('.divRegion').attr('style', 'display:none');
            //$('.divIsInclude').attr('style', 'display:none');
            //$('.divHierarchyEmp').attr('style', 'display:none');
            //$('.divEmp').attr('style', 'display:none');
            //$('.divEmpGroup').attr('style', 'display:none');
            //$('.divCustGroup').attr('style', 'display:none');
            //$('.divSS').attr('style', 'display:none');
            //$('.divDist').attr('style', 'display:none');
            // $('.btnAddConfig').attr('style', 'display:none');
            $('.divweekly').attr('style', 'display:none');
            $('.divMonthly').attr('style', 'display:none');

            // D : Daily , W : Weekly , M: Monthly
            if ($('.ddlAppliFor').val() == "W") {
                //$('.divRegion').removeAttr('style');
                //$('.divIsInclude').removeAttr('style');
                //$('.divHierarchyEmp').removeAttr('style');
                //$('.divCustGroup').removeAttr('style');
                //$('.divSS').removeAttr('style');
                //$('.divDist').removeAttr('style');
                //$('.btnAddConfig').removeAttr('style');
                $('.divweekly').removeAttr('style');
            }
            else if ($('.ddlAppliFor').val() == "M") {
                $('.divMonthly').removeAttr('style');
                for (var i = 0; i <= 31; i++) {
                    $(".ddlDay1").append($("<option></option>").val(i).html(i));
                    $(".ddlDay2").append($("<option></option>").val(i).html(i));
                    $(".ddlDay3").append($("<option></option>").val(i).html(i));
                }
                //$('.divRegion').removeAttr('style');
                //$('.divIsInclude').removeAttr('style');
                //$('.divHierarchyEmp').removeAttr('style');
                //$('.divEmp').removeAttr('style');
                //$('.divEmpGroup').removeAttr('style');
                //$('.btnAddConfig').removeAttr('style');
            }
            else {
                $('.divweekly').attr('style', 'display:none');
                $('.divMonthly').attr('style', 'display:none');
            }
        }

        function AppliForChange() {
            ClearAllInputs();
            ClearConfigControls();
            MessagePeriodChange();
            $('#tblConfig tbody').empty();
            $('#CountRowMaterial').val(0);

            $('.divRegion').attr('style', 'display:none');
            $('.divIsInclude').attr('style', 'display:none');
            $('.divDealer').attr('style', 'display:none');
            $('.divEmp').attr('style', 'display:none');
            $('.divEmpGroup').attr('style', 'display:none');
            $('.divCustGroup').attr('style', 'display:none');
            $('.divSS').attr('style', 'display:none');
            $('.divDist').attr('style', 'display:none');
            $('.btnAddConfig').attr('style', 'display:none');

            //$('.divCustomer').attr('style', 'display:none');
            $('.divEmployee').attr('style', 'display:none');

            if ($('.ddlMsgFor').val() == 'C') {
                $('.divRegion').removeAttr('style');
                $('.divIsInclude').removeAttr('style');
                $('.divDealer').removeAttr('style');
                $('.divCustGroup').removeAttr('style');
                $('.divSS').removeAttr('style');
                $('.divDist').removeAttr('style');
                $('.btnAddConfig').removeAttr('style');
                //$('.divCustomer').removeAttr('style');
            }
            else if ($('.ddlMsgFor').val() == 'E') {
                //  $('.divRegion').removeAttr('style');
                $('.divIsInclude').removeAttr('style');
                $('.divEmp').removeAttr('style');
                $('.divEmpGroup').removeAttr('style');
                $('.btnAddConfig').removeAttr('style');
                $('.divEmployee').removeAttr('style');
            }
        }

        function ClearOtherConfig() {
            if ($(this).length > 0) {
                $(".txtDealerCode").val('');
                $(".txtDistCode").val('');
            }
        }
        CustGroupID = 0;
        EmpGroupID = 0;

        //}

        function AddMoreRowMaterial() {
            var weeklyDays = "", WeekName = "";
            var Day1 = 0, Day2 = 0, Day3 = 0;
            if ($('.ddlAppliFor').val() == "0") {
                ModelMsg("Please Select message period.", 3);
                ClearConfigControls();
                return;
            }
            if ($('.ddlAppliFor').val() == "W") {
                chkSunday = $('.chkSunday').find('input').is(':checked');
                chkModay = $('.chkMonday').find('input').is(':checked');
                chkTuesday = $('.chkTuesday').find('input').is(':checked');
                chkWednesday = $('.chkWednesday').find('input').is(':checked');
                chkThursday = $('.chkThursday').find('input').is(':checked');
                chkFirday = $('.chkFriday').find('input').is(':checked');
                chkSaturday = $('.chkSaturday').find('input').is(':checked');

                var i = 0;
                if (chkSunday == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 1 + ",";
                    WeekName = WeekName + "Sunday,";
                }

                if (chkModay == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 2 + ",";
                    WeekName = WeekName + "Monday,";
                }

                if (chkTuesday == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 3 + ",";
                    WeekName = WeekName + "Tuesday,";
                }

                if (chkWednesday == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 4 + ",";
                    WeekName = WeekName + "Wednesday,";
                }

                if (chkThursday == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 5 + ",";
                    WeekName = WeekName + "Thursday,";
                }

                if (chkFirday == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 6 + ",";
                    WeekName = WeekName + "Friday,";
                }

                if (chkSaturday == true) {
                    i = i + 1;
                    weeklyDays = weeklyDays + 7 + ",";
                    WeekName = WeekName + "Saturday,";
                }
                if (i != 2) {
                    ModelMsg("Please Select only 2 days.", 3);
                    //ClearConfigControls();
                    return;
                }
            }
            else if ($('.ddlAppliFor').val() == "M") {
                Day1 = $('.ddlDay1').val();
                Day2 = $('.ddlDay2').val();
                Day3 = $('.ddlDay3').val();
                if (Day1 == 0 && Day2 == 0 && Day3 == 0) {
                    ModelMsg("Please Select at least 1 Date", 3);
                    return;
                }
                if (Day1 > 0 && Day2 > 0) {
                    if (Day1 == Day2) {
                        ModelMsg("You can not select same Date on Date 1 and Date 2", 3);
                        return;
                    }
                }
                if (Day1 > 0 && Day3 > 0) {
                    if (Day1 == Day3) {
                        ModelMsg("You can not select same Date on Date 1 and Date 3", 3);
                        return;
                    }
                }
                if (Day2 > 0 && Day3 > 0) {
                    if (Day2 == Day3) {
                        ModelMsg("You can not select same date on Date 2 and Date 3", 3);
                        return;
                    }
                }
            }

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            var MessagePeriod = $('.ddlAppliFor').val() == "W" ? "Weekly" : $('.ddlAppliFor').val() == "M" ? "Monthly" : "Daily";
            var fromdate = ($('.fromdate').length > 0 && $('.fromdate').val() != "") ? $('.fromdate').val() : "";
            var TodDate1 = ($('.todate').length > 0 && $('.todate').val() != "") ? $('.todate').val() : "";
            var MessageTo = $('.ddlMsgFor').val() == "E" ? "Employee" : "Customer";
            var MessageBody = ($('.txtMessageBody').length > 0 && $('.txtMessageBody').val() != "") ? $('.txtMessageBody').val() : "";
            var RegionData = ($('.txtDistRegion').length > 0 && $('.txtDistRegion').val() != "") ? $('.txtDistRegion').val().split('-') : "";
            var SuperStockiest = ($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-') : "";
            var DistriData = ($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-') : "";
            var DealerData = ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-') : "";
            var EmpGroupData = ($('.txtEmpGroup').length > 0 && $('.txtEmpGroup').val() != "") ? $('.txtEmpGroup').val().split('#') : "";
            var EmpData = ($('.txtEmpCode').length > 0 && $('.txtEmpCode').val() != "") ? $('.txtEmpCode').val().split('-') : "";

            var BlankVal = '';

            if (fromdate == "" && TodDate1 == "" && MessageBody == "" && RegionData == "" && SuperStockiest == "" & fromdateData == "" && DealerData == "" && EmpGroupData == "" && EmpData == "") {
                ModelMsg("Please Select atlease one configuration.", 3);
                return;
            }
            //var cntTotalConfi = [], index = 0;
            //if (RegionData != "") {
            //    cntTotalConfi[index] = RegionData;
            //    index = index + 1;
            //}
            //if (fromdate != "") {
            //    cntTotalConfi[index] = fromdate;
            //    index = infromdate
            //}
            //if (TodDate1 != "")fromdate        //    cntTotalConfi[index] = TodDate1;
            //    index = index + 1;
            //}
            //if (MessageTo != "") {
            //    cntTotalConfi[index] = MessageTo;
            //    index = index + 1;
            //}
            //if (SuperStockiest != "") {
            //    cntTotalConfi[index] = SuperStockiest;
            //    index = index + 1;
            //}
            //if (DistriData != "") {
            //    cntTotalConfi[index] = DistriData;
            //    index = index + 1;
            //}
            //if (DealerData != "") {
            //    cntTotalConfi[index] = DealerData;
            //    index = index + 1;
            //}

            //if (cntTotalConfi.length > 1) {
            //    ModelMsg("You can not select more than one configuration.", 3);
            //    cntTotalConfi.length = 0;
            //    return;
            //}

            str = "<tr id='trMaterial" + ind + "'>"
               + "<td><label for='Region' id='lblRegion" + ind + "'>" + (RegionData.length > 0 ? RegionData[0].trim() + "#" + RegionData[1].trim() : BlankVal) + " </label></td>"
               //+ "<td><label for='FromDate' id='lblFromDate" + ind + "'> " + (fromdate.length > 0 ? fromdate.trim() : BlankVal) + " </label></td>"
               //+ "<td><labefromdateoDate' id='lblfromdate+ ind + "'> " + (TodDate1.length > 0 ? TodDate1 : BlankVal) + " </label></td>"
               //+ "<td><label for='MessagePeriod' id='lblmessageperiod" + ind + "'> " + (MessagePeriod.length > 0 ? MessagePeriod.trim() : BlankVal) + " </label></td>"
               //+ "<td><label for='MessageTo' id='lblMessageTo" + ind + "'> " + (MessageTo.length > 0 ? MessageTo.trim() : BlankVal) + " </label></td>"
               + "<td><label for='SS' id='lblSS" + ind + "'> " + (SuperStockiest.length == 3 ? SuperStockiest[0].trim() + "#" + SuperStockiest[1].trim() : BlankVal) + " </label></td>"
               + "<td><label for='Distributor' id='lblDistributor" + ind + "'> " + (DistriData.length == 3 ? DistriData[0].trim() + "#" + DistriData[1].trim() : BlankVal) + " </label></td>"
               + "<td><label for='Dealer' id='lblDealer" + ind + "'> " + (DealerData.length == 3 ? DealerData[0].trim() + "#" + DealerData[1].trim() : BlankVal) + " </label></td>"

               + "<td><label for='EmpGroup' id='lblEmpGroup" + ind + "'> " + (EmpGroupData.length == 3 ? EmpGroupData[0].trim() + "#" + EmpGroupData[1].trim() : BlankVal) + " </label></td>"
               + "<td><label for='Employee' id='lblEmployee" + ind + "'> " + (EmpData.length == 3 ? EmpData[0].trim() + "#" + EmpData[1].trim() : EmpData.length == 4 ? EmpData[0].trim() + "#" + EmpData[1].trim() : BlankVal) + " </label></td>"

               + "<td><label for='WeekDays' id='lblWeekDays" + ind + "'> " + WeekName + " </label></td>"
               + "<td style='text-alignment:right;'><label for='Day1' name='lblDay1' id='lblDay1" + ind + "'> " + Day1 + " </label></td>"
               + "<td style='text-alignment:right;'><label for='Day2' name='lblDay2' id='lblDay2" + ind + "'> " + Day2 + " </label></td>"
               + "<td style='text-alignment:right;'><label for='Day3' name='lblDay3' id='lblDay3" + ind + "'> " + Day3 + " </label></td>"

               + "<td><label for='IsInclude' id='lblIsInclude" + ind + "'> " + $('.chkIsInclude > input[type=checkbox]').prop('checked') + " </label></td>"
               + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:18px;' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
               + "<input type='hidden' id='hdnweekID" + ind + "' name='hdnweekID' value='" + weeklyDays + "' />"
               + "<input type='hidden' id='hdnMessagePeriodID" + ind + "' name='hdnMessagePeriodID' value='" + $('.ddlAppliFor').val() + "' />"
               + "<input type='hidden' id='hdnMessageTO" + ind + "' name='hdnMessageTO' value='" + $('.ddlMsgFor').val() + "' />"
               + "<input type='hidden' id='hdnRegionID" + ind + "' name='hdnRegionID' value='" + (RegionData.length > 1 ? RegionData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnDealerID" + ind + "' name='hdnDealerID' value='" + (DealerData.length > 1 ? DealerData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnSSID" + ind + "' name='hdnSSID' value='" + (SuperStockiest.length == 3 ? SuperStockiest[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnDistriID" + ind + "' name='hdnDistriID' value='" + (DistriData.length == 3 ? DistriData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnEmpGroupID" + ind + "' name='hdnEmpGroupID' value='" + (EmpGroupData.length == 3 ? EmpGroupData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnEmpID" + ind + "' name='hdnEmpID' value='" + (EmpData.length == 3 ? EmpData[2].trim() : EmpData.length == 4 ? EmpData[3].trim() : 0) + "' />"
               + "</tr>"

            $('#tblConfig > tbody ').append(str);
            ClearConfigControls();
            $('.divCustomer').removeAttr('style');
        }

        var WeekDays = [['1', 'Sunday'], ['2', 'Monday'], ['3', 'Tuesday'], ['4', 'Wednesday'], ['5', 'Thursday'], ['6', 'Friday'], ['7', 'Saturday']];
        //var WeekDays = [[ '1', 'Sunday' ], { key: 2, value: 'Monday' }, { key: 3, value: 'Tuesday' }, { key: 4, value: 'Wednesday' }, { key: 5, value: 'Thursday' }, { key: 6, value: 'Friday' }, { key: 7, value: 'Saturday' }];
        //var WeekDays = { 1: "Sunday", 2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday", 7: "Saturday" };
        function GetMessageDetailByID(MessageID) {
            var Week = "";
            var sv = $.ajax({
                url: 'WhatsAppBusinessConfiguation.aspx/GetMessageDetailByID',
                type: 'POST',
                async: true,
                traditional: true,
                dataType: 'json',
                data: JSON.stringify({ MessageID: MessageID }),
                contentType: 'application/json; charset=utf-8'
            });

            sv.success(function (result) {
                $('#tblConfig tbody').empty();
                if (result.d == "") {
                    return false;
                }
                else if (result.d.indexOf("ERROR=") >= 0) {
                    var ErrorMsg = result.d.split('=')[1].trim();
                    ModelMsg(ErrorMsg, 3);
                    return false;
                }
                else {
                    for (var i = 0; i < result.d.length; i++) {

                        if (i == 0) {
                            //$(".ddlAppliFor option[value=" + result.d[i]['AppliFor'].trim() + "]").attr('selected', 'selected');
                            $(".ddlAppliFor").val(result.d[i]['AppliFor'].trim());
                            MessagePeriodChange();
                            //$(".ddlMsgFor option[value=" + result.d[i]['MessageTo'].trim() + "]").attr('selected', 'selected');
                            $(".ddlMsgFor").val(result.d[i]['MessageTo'].trim());
                            AppliForChange();
                            $('.txtMessageCode').val(MessageID);
                            //$('.txtSubject').val(result.d[i]['Subject']);
                            $('.fromdate').val(moment(result.d[i]['FromDate']).format("DD/MM/YYYY"));
                            $('.todate').val(moment(result.d[i]['ToDate']).format("DD/MM/YYYY"));
                            $('.txtCreatedBy').val(result.d[i]['CreatedBy']);
                            $('.txtCreatedTime').val(result.d[i]['CreatedTime']);
                            $('.txtUpdatedBy').val(result.d[i]['UpdatedBy']);
                            $('.txtUpdatedTime').val(result.d[i]['UpdatedTime']);
                            // $('.txtMessageBody').val(result.d[i]['Body']);

                            $('.chkActive > input[type=checkbox]').prop('checked', result.d[i]['IsActive']);
                            $('.messageimg').attr('src', result.d[i]['ImageUpload']);
                            if (result.d[i]['ImageUpload'] != "") {
                                $('.hdnImageHasValue').val(result.d[i]['ImageUpload']);
                                $('.messageimg').css('display', 'block');
                            }
                            else {
                                $('.hdnImageHasValue').val('');
                                $('.messageimg').css('display', 'none');
                            }
                            //$('.ddlAppliFor').val(result.d[i]['AppliFor']).trigger('change');
                        }
                        else {

                            var ind = $('#CountRowMaterial').val();
                            ind = parseInt(ind) + 1;
                            $('#CountRowMaterial').val(ind);
                            var str = "";
                            var BlankVal = '';
                            Week = "";
                            $(".ddlDay1 option[value=" + result.d[i]['Day1'] + "]").attr('selected', 'selected');
                            $(".ddlDay2 option[value=" + result.d[i]['Day2'] + "]").attr('selected', 'selected');
                            $(".ddlDay3 option[value=" + result.d[i]['Day3'] + "]").attr('selected', 'selected');
                            if (result.d[i]["WeekDays"] != "") {
                                var ArrayWeekDays = [];
                                ArrayWeekDays = result.d[i]["WeekDays"].split(',');
                                const myMap = new Map(WeekDays);
                                for (var j = 0; j < ArrayWeekDays.length; j++) {
                                    Week = Week + myMap.get(ArrayWeekDays[j]) + ",";
                                }
                            }
                            //alert(WeekDays[ArrayWeekDays[j]]);
                            //Week = WeekDays.ArrayWeekDays[j] + ",";
                            //WeekDays
                            //    }
                            var EmpGroup = "";
                            if (result.d[i]['EmpCustGroup'] != null) {
                                EmpGroup = result.d[i]['EmpCustGroup'];
                            }
                            str = "<tr id='trMaterial" + ind + "'>"
                                  + "<td><label for='Region' id='lblRegion" + ind + "'>" + result.d[i]['Region'] + " </label></td>"
                                  + "<td><label for='SS' id='lblSS" + ind + "'> " + result.d[i]['SSCode'] + " </label></td>"
                                  + "<td><label for='Distributor' id='lblDistributor" + ind + "'> " + result.d[i]['DistributorEmp'] + " </label></td>"
                                  + "<td><label for='Distributor' id='lblDistributor" + ind + "'> " + result.d[i]['DealerEmp'] + " </label></td>"
                                  + "<td><label for='EmpGroup' id='lblEmpGroup" + ind + "'> " + EmpGroup + " </label></td>"
                                  + "<td><label for='Employee' id='lblEmployee" + ind + "'> " + result.d[i]['EmpCustName'] + " </label></td>"
                                  + "<td><label for='Employee' id='lblWeekDays" + ind + "'> " + Week + " </label></td>"
                                  + "<td><label for='Employee' name='lblDay1' id='lblDay1" + ind + "'> " + result.d[i]['Day1'] + " </label></td>"
                                  + "<td><label for='Employee' name='lblDay2' id='lblDay2" + ind + "'> " + result.d[i]['Day2'] + " </label></td>"
                                  + "<td><label for='Employee' name='lblDay3' id='lblDay3" + ind + "'> " + result.d[i]['Day3'] + " </label></td>"
                                  + "<td><label for='IsInclude' id='lblIsInclude" + ind + "'> " + result.d[i]['IsInclude'] + " </label></td>"
                                  + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:18px;' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
                                  + "<input type='hidden' id='hdnRegionID" + ind + "' name='hdnRegionID' value='" + result.d[i]['RegionID'] + "' />"
                                  + "<input type='hidden' id='hdnEmpGroupID" + ind + "' name='hdnEmpGroupID' value='" + (result.d[i]['AppliFor'] == 'E' ? result.d[i]['EmpCustGroupID'] : 0) + "' />"
                                  + "<input type='hidden' id='hdnEmpID" + ind + "' name='hdnEmpID' value='" + (result.d[i]['AppliFor'] == 'E' ? result.d[i]['EmpCustID'] : 0) + "' />"
                                  + "<input type='hidden' id='hdnSSID" + ind + "' name='hdnSSID' value='" + result.d[i]['SSID'] + "' />"
                                  + "<input type='hidden' id='hdnDistriID" + ind + "' name='hdnDistriID' value='" + result.d[i]['DistributorID'] + "' />"
                                  + "<input type='hidden' id='hdnDealerID" + ind + "' name='hdnDealerID' value='" + result.d[i]['DealerID'] + "' />"
                                  + "<input type='hidden' id='hdnweekID" + ind + "' name='hdnweekID' value='" + result.d[i]['WeekDays'] + "' />"
                                  + "</tr>"



                            $('#tblConfig > tbody').append(str);
                            ClearConfigControls();
                            $('.divCustomer').removeAttr('style');
                        }
                    }

                }
            });

            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {

                ModelMsg('Something is wrong...' + XMLHttpRequest.responseText, 3);
                return false;
            });
        }
        function CheckFile(event) {
            var file = event.files[0];
            if (file.size >= 2 * 1024 * 1024) {
                alert("Image file size should be maximum 2MB.");
                $(event).val('');
                return;
            }
            
            var ext = file.name.replace(/^.*\./, '').toLowerCase();

            if (ext == "jpg" || ext == "png" || ext == "gif" || ext == "jpeg" || ext == "pdf") {

            }
            else {
                alert("You can upload only Pdf and Image File.");
                $(event).val('');
                return;
            }

            if (file.size >= 16 * 1024 * 1024) {
                alert("Video file size should be maximum 16MB and 3 Minutes.");
                $(event).val('');
                return;
            }

            if (ext == "mp4" ) {

            }
            else {
                alert("You can upload only Video File.");
                $(event).val('');
                return;
            }
        }

    </script>

    <style>
        .table > tbody > tr > td > label {
            font-weight: normal;
        }

        .gvScheduleData tbody tr td, .gvScheduleData tbody tr th {
            padding: 6px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <%--<input type="checkbox" id="chkMode" tabindex="1" name="onoffswitch" class="chkMode _auchk" style="margin-bottom: 10px" onchange="ClearAllInputs();" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" checked="checked" />--%>
        <input type="checkbox" name="onoffswitch" class="_auchk" tabindex="1" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <%-- <div class="row">--%>
            <div class="row _masterForm">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblMessageCode" runat="server" Text="No" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtMessageCode" runat="server" TabIndex="2" CssClass="form-control" OnTextChanged="txtMessageCode_TextChanged" data-bv-notempty="true" data-bv-notempty-message="Field is required" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtMessageCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetWhatsAppMessage" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMessageCode" OnClientPopulating="autoCompleteMessageCode_OnClientPopulating"
                            OnClientItemSelected="onAutoCompleteSelected" Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="Label6" runat="server" Text="Message Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlMessageType" CssClass="form-control " TabIndex="3" AutoPostBack="true" OnSelectedIndexChanged="ddlMessageType_SelectedIndexChanged">
                            <asp:ListItem Text="Sales Invoice" Value="Sales Invoice" Selected="True" />
                            <asp:ListItem Text="Sales Return" Value="Sales Return" />
                            <asp:ListItem Text="Promotional" Value="Promotional" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblfromdate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtfromdate" runat="server" MaxLength="10" TabIndex="4" onfocus="this.blur();" onkeyup="return ValidateDate(this);" data-bv-notempty="true" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lbltodate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txttodate" runat="server" TabIndex="5" MaxLength="10" onfocus="this.blur();" onkeyup="return ValidateDate(this);" data-bv-notempty="true" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div style="float: right; margin-right: 40px;">
                    <asp:Button ID="btnSubmit" CssClass="btn btn-success" runat="server" TabIndex="31" Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" ValidationGroup="cmgroup" />
                    <asp:Button ID="btnCancel" CssClass="btn btn-danger" runat="server" TabIndex="32" Text="Cancel" UseSubmitBehavior="false" CausesValidation="false" OnClick="btnCancel_Click" />
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab">Customer/Employee</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">
                    <div class="row _masterForm">
                        <div class="col-lg-12">

                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:Label ID="Label2" runat="server" Text="Active" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkActive" CssClass="chkActive form-control" runat="server" TabIndex="26" />
                                </div>
                            </div>
                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:FileUpload ID="flCUpload" Visible="false" runat="server" CssClass="form-control" EnableViewState="true" TabIndex="30" />
                                    <input type="hidden" runat="server" id="hdnImageFile" class="hdnImageFile" />
                                </div>
                            </div>
                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCCMobileNO" runat="server" Text="CCMobile-Number" CssClass="input-group-addon" TabIndex="26" onfocus="this.blur();"></asp:Label>
                                    <asp:TextBox ID="txtMobileNo" runat="server" data-bv-stringlength="false" MaxLength="10" placeholder="Mobile"
                                                onkeypress="return isNumberKey(event);" onDrop="blur(); return false;" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ValidationGroup="cmgroup" ErrorMessage="Mobile Number must Starts with '6,7,8 or 9' only." ControlToValidate="txtMobileNo" ForeColor="Red" ValidationExpression="^[6-9]\d{9}$"></asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="col-lg-3">
                                <div class="input-group form-group" style="margin-left: 10px">
                                    <asp:Image Style="max-width: 100%; max-height: 40px;" runat="server" ID="imgMessage" />
                                    <asp:HiddenField ID="hdnImageHasValue" runat="server" Value="" />
                                </div>
                            </div>
                            
                        </div>

                        <div class="col-lg-12">
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon" onCopy="return false;"></asp:Label>
                                    <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
                <div id="tabs-2" class="tab-pane">
                    <div class="row _masterForm">
                        <div class="col-lg-12">
                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblApplicableFor" runat="server" Text="Message Period" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlAppliFor" CssClass="form-control " TabIndex="6" AutoPostBack="true" onchange="AppliForChange();" OnSelectedIndexChanged="ddlAppliFor_SelectedIndexChanged">
                                        <asp:ListItem Text="Daily" Value="D" Selected="True" />
                                        <asp:ListItem Text="Weekly" Value="W" />
                                        <asp:ListItem Text="Monthly" Value="M" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div id="divMonthly" runat="server">
                                <div class="col-lg-3">
                                    <div class="input-group form-group">
                                        <asp:Label ID="Label3" runat="server" Text="Date 1" CssClass="input-group-addon"></asp:Label>
                                        <asp:DropDownList runat="server" ID="ddlDay1" CssClass="form-control " TabIndex="16">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-lg-3">
                                    <div class="input-group form-group">
                                        <asp:Label ID="Label4" runat="server" Text="Date 2" CssClass="input-group-addon"></asp:Label>
                                        <asp:DropDownList runat="server" ID="ddlDay2" CssClass="form-control " TabIndex="17">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-lg-3">
                                    <div class="input-group form-group">
                                        <asp:Label ID="Label5" runat="server" Text="Date 3" CssClass="input-group-addon"></asp:Label>
                                        <asp:DropDownList runat="server" ID="ddlDay3" CssClass="form-control " TabIndex="18">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div id="divweekly" runat="server" class="col-lg-9">
                                <div class="input-group form-group">
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkMonday" TabIndex="19" CssClass="chkMonday" runat="server" />
                                        <asp:Label Text="Monday" runat="server" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkTuesday" TabIndex="20" CssClass="chkTuesday" runat="server" />
                                        <asp:Label Text="Tuesday" runat="server" for="chkTuesday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkWednesday" TabIndex="21" CssClass="chkWednesday" runat="server" />
                                        <asp:Label Text="Wednesday" runat="server" for="chkWednesday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkThursday" TabIndex="22" CssClass="chkThursday" runat="server" />
                                        <asp:Label Text="Thursday" runat="server" for="chkThursday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkFriday" TabIndex="23" CssClass="chkFriday" runat="server" />
                                        <asp:Label Text="Friday" runat="server" for="chkFriday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkSaturday" TabIndex="24" CssClass="chkSaturday" runat="server" />
                                        <asp:Label Text="Saturday" runat="server" for="chkSaturday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkSunday" TabIndex="25" CssClass="chkSunday" runat="server" />
                                        <asp:Label Text="Sunday" runat="server" for="chkSunday" Style="vertical-align: super" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">

                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:Label ID="Label1" runat="server" Text="Message To" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlMsgFor" CssClass="ddlMsgFor form-control " TabIndex="7" onchange="MessagePeriodChange();" OnSelectedIndexChanged="ddlMsgFor_SelectedIndexChanged" AutoPostBack="true">
                                        <asp:ListItem Text="Employee" Value="E" Selected="True" />
                                        <asp:ListItem Text="Customer" Value="C" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-3 divEmpGroup" runat="server" id="divEmpGroup">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon" runat="server" />
                                    <asp:TextBox runat="server" ID="txtEmpGroup" CssClass="txtEmpGroupId form-control" Style="background-color: rgb(250, 255, 189);" TabIndex="8" onDrop="blur(); return false;"/>
                                    <asp:AutoCompleteExtender ID="aceEmpGroup" runat="server" TargetControlID="txtEmpGroup" ServiceMethod="GetEmployeeGroup" ServicePath="~/WebService.asmx"
                                        OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                                        MinimumPrefixLength="1" UseContextKey="true" OnClientPopulating="txtEmpGroup_OnClientPopulating">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3" id="divEmp" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtEmpCode" runat="server" CssClass="form-control txtEmployeeCode" TabIndex="9" Style="background-color: rgb(250, 255, 189);" onDrop="blur(); return false;"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetEmployeeListByGroup" MinimumPrefixLength="1" CompletionInterval="10"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmpCode" OnClientPopulating="acettxtEmpCode_OnClientPopulating">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3" id="divmessageFor" runat="server" visible="false">
                                <div class="input-group form-group">
                                    <asp:Label ID="Label7" runat="server" Text="Message For" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlMessageFor" CssClass="ddlMessageForType form-control " TabIndex="10" OnSelectedIndexChanged="ddlMessageFor_SelectedIndexChanged" AutoPostBack="true">
                                        <asp:ListItem Value="SS" Text="Super Stockist"></asp:ListItem>
                                        <asp:ListItem Value="Distributor" Text="Distributor"></asp:ListItem>
                                        <asp:ListItem Value="Dealer" Text="Dealer"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-3 divRegion" id="divRegion" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtRegion" CssClass="txtRegionName form-control" OnChange="ClearAllTextboxConfig()" runat="server" Style="background-color: rgb(250, 255, 189);" onDrop="blur(); return false;" TabIndex="11"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                                        ServiceMethod="GetDistributorRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                        TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3" id="divEmpCustomer" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label ID="Label8" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtEmpCustCode" runat="server" CssClass="txtEmpCust form-control" OnChange="ClearAllTextOnEmployeeConfig()" TabIndex="12" Style="background-color: rgb(250, 255, 189);" onDrop="blur(); return false;"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetEmployeeListByRegion" MinimumPrefixLength="1" CompletionInterval="10"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmpCustCode" OnClientPopulating="acettxtEmpCustCode_OnClientPopulating">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3 divSS" id="divSS" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSSCustomer" runat="server" Text="SS Name" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSSCode" runat="server" TabIndex="13" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCodeName form-control" onDrop="blur(); return false;"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3 divDist" id="divDist" runat="server">
                                <div class="input-group form-group divDistributor" id="divDistributor" runat="server">
                                    <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtDistributor" runat="server" TabIndex="14" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistri form-control" autocomplete="off" onDrop="blur(); return false;"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtDist" runat="server"
                                        ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetDistCurrHierarchy" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                                        CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistributor">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3 divDealer" id="divDealer" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustGroup" Text="Dealer" CssClass="input-group-addon" runat="server" />
                                    <asp:TextBox runat="server" ID="txtDealer" CssClass="txtDealerName form-control" Style="background-color: rgb(250, 255, 189);" TabIndex="15" onDrop="blur(); return false;" />
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealer">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:Label ID="Label9" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkIsActive" CssClass="chkActive form-control" runat="server" TabIndex="26" />
                                </div>
                            </div>
                            <div class="col-lg-3 divIsInclude">
                                <div class="input-group form-group">
                                    <asp:Label ID="Label10" Text="Is Include" runat="server" CssClass="input-group-addon" />
                                    <asp:CheckBox ID="chkIsInclude" CssClass="chkIsInclude form-control" runat="server" TabIndex="27" Checked="true" />
                                </div>
                            </div>
                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <%--<input type="button" value="Add Configuration" id="btnAddConfig" name="btnAddConfig" tabindex="25" class="btnAddConfig btn btn-info" style="display: none;" onclick="AddMoreRowMaterial();" />--%>
                                    <asp:Button ID="btnAddScheduleData" runat="server" TabIndex="28" Text="Add" CssClass="btn btn-info button" Style="margin-right: 8px;" OnClick="btnAddScheduleData_Click" />
                                    <asp:Button ID="btnCancleScheduleData" runat="server" TabIndex="29" Text="Clear" CssClass="btn btn-warning" OnClick="btnCancleScheduleData_Click" />
                                    <input type="hidden" id="CountRowMaterial" />
                                    <input type="hidden" id="hidJsonInputMaterial" class="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                                    <input type="hidden" id="hidJsonInputHeader" class="hidJsonInputHeader" name="hidJsonInputHeader" value="" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <asp:GridView runat="server" ID="gvScheduleData" Width="100%" Style="font-size: 10px;" AutoGenerateColumns="false" CssClass="table gvScheduleData" HeaderStyle-CssClass="table-header-gradient"
                                EmptyDataText="No Record Found." OnRowCommand="gvSchedule_RowCommand">
                                <Columns>
                                    <asp:TemplateField HeaderText="No." ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Label ID="lblGNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                            <asp:Label ID="lblMessagePeriod" runat="server" Visible="false" Text='<%# Bind("MessagePeriod") %>'></asp:Label>
                                        </ItemTemplate>
                                        <HeaderStyle Width="3%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Edit" ItemStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="editData" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="3%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Delete" ItemStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnDetails" runat="server" Text="Delete" CommandName="deleteData" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="4%" />
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Employee Group" DataField="EmpGroup" HeaderStyle-Width="7%" />
                                    <asp:BoundField HeaderText="Employee" DataField="EmpName" HeaderStyle-Width="12%" />
                                    <asp:BoundField HeaderText="Region" DataField="RegionName" HeaderStyle-Width="6%" />
                                    <asp:BoundField HeaderText="Super Stockist" DataField="SSCode" HeaderStyle-Width="12%" />
                                    <asp:BoundField HeaderText="Distributor" DataField="DistributorCode" HeaderStyle-Width="10%" />
                                    <asp:BoundField HeaderText="Dealer" DataField="DealerCode" HeaderStyle-Width="10%" />
                                    <asp:BoundField HeaderText="Week Days" DataField="WeekDayName" HeaderStyle-Width="8%" />
                                    <asp:BoundField HeaderText="Date 1" DataField="Day1" HeaderStyle-Width="3.5%" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Date 2" DataField="Day2" HeaderStyle-Width="3.5%" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Date 3" DataField="Day3" HeaderStyle-Width="3.5%" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Include" DataField="IsInclude" HeaderStyle-Width="4%" />
                                    <asp:BoundField HeaderText="Active" DataField="Active" HeaderStyle-Width="3.5%" />
                                    <asp:BoundField HeaderText="Created Date" DataField="CreatedDate" HeaderStyle-Width="7%" DataFormatString="{0:dd/MM/yy}" />
                                    <asp:BoundField HeaderText="Created Time" DataField="UpdateDate" HeaderStyle-Width="7%" DataFormatString="{0:HH:mm}" />
                                </Columns>
                            </asp:GridView>
                            <table id="tblConfig" class="tblConfig table table-bordered nowrap" border="1" style="width: 100%; border-collapse: collapse; font-size: 11px; margin-top: 0px; margin-bottom: 0px; margin-left: 10px; display: none;">
                                <thead>
                                    <tr class="table-header-gradient" style="margin-left: 2px">
                                        <th style="width: 7%">Sr No.</th>
                                        <th style="width: 7%">Edit</th>
                                        <th style="width: 7%">Delete</th>
                                        <th style="width: 10%">Dist Region</th>
                                        <th style="width: 16%">SS</th>
                                        <th style="width: 16%">Distributor</th>
                                        <th style="width: 16%">Dealer</th>
                                        <th style="width: 10%">Employee Group</th>
                                        <th style="width: 16%">Employee</th>
                                        <th style="width: 16%">Week Days</th>
                                        <th style="width: 6%">Day 1</th>
                                        <th style="width: 6%">Day 2</th>
                                        <th style="width: 6%">Day 3</th>
                                        <th style="width: 8%">Is Inc</th>
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
    </div>
            </div>
        </div>
    </div>
</asp:Content>
