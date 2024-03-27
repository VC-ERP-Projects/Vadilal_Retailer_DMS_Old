<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="MessageBroadCast.aspx.cs" Inherits="Marketing_MessageBroadCast" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
   
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

      

    <script type="text/javascript">

        var AvailableMessage = [];
        var CustGroupID = 0, EmpGroupID = 0;
        var MaxLengthMsgBody = 500;
        
        $(document).ready(function () {
          
            $('#CountRowMaterial').val(0);
            AppliForChange();
            $("#tblConfig").tableHeadFixer('34vh');
            $('.txtMessageBody').keypress(function (e) {
                if ($(this).val().length >= MaxLengthMsgBody) {
                    e.preventDefault();
                }
            });

            $('.txtCustGroup').focusout(function () {

                if ($('.txtCustGroup').val().length > 0) {

                    var sv = $.ajax({
                        url: 'MessageBroadCast.aspx/GetCustGroupID',
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

            $('.txtEmpGroup').focusout(function () {

                if ($('.txtEmpGroup').val().split("#")[0].trim().length > 0) {

                    var sv = $.ajax({
                        url: 'MessageBroadCast.aspx/GetEmpGroupID',
                        type: 'POST',
                        async: false,
                        traditional: true,
                        dataType: 'json',
                        data: JSON.stringify({ EmpGroupName: $('.txtEmpGroup').val().split("#")[0].trim() }),
                        contentType: 'application/json; charset=utf-8'
                    })

                    sv.success(function (result) {
                        if (result.d == "" || result.d == "0") {
                            ModelMsg('Emp Group Detail Not found. Pease re-select Emp group.', 3);
                            $('.txtEmpGroup').val('');
                        }
                        else {
                            EmpGroupID = result.d;
                        }
                    });

                    sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                        ModelMsg('Emp Group Detail Not found. Pease select proper customer group.' + XMLHttpRequest.responseText, 3)
                        return false;
                    });
                }

            });

            $('.fromdate1').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //minDate: '0',
            });

            $('.todate1').datepicker({
                //numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //minDate: '0'
            });
        });

        function autoCompleteMessageCode_OnClientPopulating(sender, args) {
            var key = $('.ddlAppliFor option:selected').val();
            sender.set_contextKey(key);
        }
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            sender.set_contextKey(reg + "-0-" + "0");
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var ss = $('.txtSSCode').val().split('-').pop();
            sender.set_contextKey(reg + "-0-" + "0" + "-" + ss);
        }
        function GetSelectedID() {
            var messageCode = $('.txtMessageCode').val().split('-')[0];
            GetMessageDetailByID(messageCode.trim());
        }
        function RemoveMaterialRow(row) {
            $('#trMaterial' + row).remove();
        }

        function ClearConfigControls() {

            CustGroupID = 0;
            EmpGroupID = 0;
            $('.txtRegion').val('');
            $('.txtEmpGroup').val('');
            $('.txtEmpCode').val('');
            $('.txtSSCode').val('');
            $('.txtDistCode').val('');
            $('.txtCustGroup').val('');
            $('.txtHrEmpCode').val('');
          
            $('.chkIsInclude > input[type=checkbox]').prop('checked', true);
        }

        function ClearAllInputs() {

            $('.hidJsonInputHeader').val('');
            $('.hidJsonInputMaterial').val('');
            $('.txtMessageCode').removeAttr("disabled");
            $('.txtMessageCode').val('');
            $('.txtSubject').val('');
            $('.fromdate1').val('');
            $('.todate1').val('');
            $('.txtMessageBody').val('');
            var htmlEditorExtender = $('.ajax__html_editor_extender_texteditor');
            htmlEditorExtender.html('');
            $('.messageimg').css('display', 'none');
            $('.messageimg').attr('src', '#');

            $('.txtRegion').val('');
            $('.txtEmpGroup').val('');
            $('.txtEmpCode').val('');
            $('.txtSSCode').val('');
            $('.txtDistCode').val('');
            $('.txtCustGroup').val('');
            $('.txtHrEmpCode').val('');
            $('.chkIsInclude > input[type=checkbox]').prop('checked', true);
            $('#tblConfig tbody').empty();
            $('#CountRowMaterial').val(0);
            $('.chkActive > input[type=checkbox]').prop('checked', true);
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
        function AppliForChange() {
            ClearAllInputs();
            ClearConfigControls();
            $('#tblConfig tbody').empty();
            $('#CountRowMaterial').val(0);

            $('.divRegion').attr('style', 'display:none');
            $('.divIsInclude').attr('style', 'display:none');
            $('.divHierarchyEmp').attr('style', 'display:none');
            $('.divEmp').attr('style', 'display:none');
            $('.divEmpGroup').attr('style', 'display:none');
            $('.divCustGroup').attr('style', 'display:none');
            $('.divSS').attr('style', 'display:none');
            $('.divDist').attr('style', 'display:none');
            $('.btnAddConfig').attr('style', 'display:none');
            $('.divEmpGroupCode').attr('style', 'display:none');
           

            if ($('.ddlAppliFor').val() == 'C') {
                $('.divRegion').removeAttr('style');
                $('.divIsInclude').removeAttr('style');
                $('.divHierarchyEmp').removeAttr('style');
                $('.divCustGroup').removeAttr('style');
                $('.divSS').removeAttr('style');
                $('.divDist').removeAttr('style');
                $('.btnAddConfig').removeAttr('style');
                $('.divEmpGroupCode').attr('style', 'display:none');
            }
            else if ($('.ddlAppliFor').val() == 'E') {
                $('.divRegion').removeAttr('style');
                $('.divIsInclude').removeAttr('style');
                $('.divHierarchyEmp').removeAttr('style');
                $('.divEmp').removeAttr('style');
                $('.divEmpGroup').removeAttr('style');
                $('.btnAddConfig').removeAttr('style');
                $('.divEmpGroupCode').attr('style', 'display:none');
            }
            else if ($('.ddlAppliFor').val() == 'F') {
                $('.divRegion').removeAttr('style');
                $('.divIsInclude').removeAttr('style');
                /*  $('.divHierarchyEmp').removeAttr('style');*/
                $('.divEmp').removeAttr('style');
                /* $('.divEmpGroup').removeAttr('style');*/
                /*  $('.divEmpGroup').removeAttr('style');*/
                $('.divEmpGroupCode').removeAttr('style');
                $('.divHierarchyEmp').attr('style', 'display:none');
                $('.divEmpGroup').removeAttr('style');
                $('.divSS').attr('style', 'display:none');
                $('.divDist').attr('style', 'display:none');
                $('.btnAddConfig').removeAttr('style');
            }
           

        }


        CustGroupID = 0;
        EmpGroupID = 0;

        //}

        function AddMoreRowMaterial() {

            if ($('.ddlAppliFor').val() == "0") {
                ModelMsg("Please Select applicable for.", 3);
                ClearConfigControls();
                return;
            }

           
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";

            var RegionData = ($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-') : "";
            var EmpGroupData = ($('.txtEmpGroup').length > 0 && $('.txtEmpGroup').val() != "") ? $('.txtEmpGroup').val() : "";
            var EmpData = ($('.txtEmpCode').length > 0 && $('.txtEmpCode').val() != "") ? $('.txtEmpCode').val().split('-') : "";
            var HierarchyEmpData = ($('.txtHrEmpCode').length > 0 && $('.txtHrEmpCode').val() != "") ? $('.txtHrEmpCode').val().split('-') : "";
            var CustGroupData = ($('.txtCustGroup').length > 0 && $('.txtCustGroup').val() != "") ? $('.txtCustGroup').val() : "";
            var SSData = ($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-') : "";
            var DistriData = ($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-') : "";
           /* var EmployeeData = ($('.ddlEGroup').length > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup').val().split('-') : "";*/
            var BlankVal = '';

            
            if (RegionData == "" && EmpGroupData == "" && EmpData == "" && HierarchyEmpData == "" && CustGroupData == "" && SSData == "" && DistriData == "" && EmployeeData=="") {
                ModelMsg("Please Select atlease one configuration.", 3);
                return;
            }
            var cntTotalConfi = [], index = 0;
            if (RegionData != "") {
                cntTotalConfi[index] = RegionData;
                index = index + 1;
            }
            if (EmpGroupData != "") {
                cntTotalConfi[index] = EmpGroupData;
                index = index + 1;
            }
            //if (EmployeeData != "") {
            //    cntTotalConfi[index] = EmployeeData;
            //    index = index + 1;
            //}
            if (EmpData != "") {
                cntTotalConfi[index] = EmpData;
                index = index + 1;
            }
            if (HierarchyEmpData != "") {
                cntTotalConfi[index] = HierarchyEmpData;
                index = index + 1;
            }
            if (CustGroupData != "") {
                cntTotalConfi[index] = CustGroupData;
                index = index + 1;
            }
            if (SSData != "") {
                cntTotalConfi[index] = SSData;
                index = index + 1;
            }
            if (DistriData != "") {
                cntTotalConfi[index] = DistriData;
                index = index + 1;
            }

            if (cntTotalConfi.length > 1) {
                ModelMsg("You can not select more than one configuration.", 3);
                cntTotalConfi.length = 0;
                return;
            }

            str = "<tr id='trMaterial" + ind + "'>"
               + "<td><label for='Region' id='lblRegion" + ind + "'>" + (RegionData.length > 0 ? RegionData[0].trim() + "#" + RegionData[1].trim() : BlankVal) + " </label></td>"
                + "<td><label for='HierarchyEmployee' id='lblHieEmployee" + ind + "'> " + (HierarchyEmpData.length > 0 ? HierarchyEmpData[0].trim() + "#" + HierarchyEmpData[1].trim() : BlankVal) + " </label></td>"
               /* + "<td><label for='Emp.Group' id='Label1" + ind + "'>" + (EmployeeData.length > 0 ? EmployeeData[0].trim() : BlankVal) + " </label></td>"*/
                + "<td><label for='EmpGroup' id='lblEmpGroup" + ind + "'> " + (EmpGroupData.length > 0 ? EmpGroupData.trim() : BlankVal) + " </label></td>"
               + "<td><label for='Employee' id='lblEmployee" + ind + "'> " + (EmpData.length > 0 ? EmpData[0].trim() + "#" + EmpData[1].trim() : BlankVal) + " </label></td>"
               + "<td><label for='CustGroup' id='lblCustGroup" + ind + "'> " + (CustGroupData.length > 0 ? CustGroupData.trim() : BlankVal) + " </label></td>"
               + "<td><label for='SS' id='lblSS" + ind + "'> " + (SSData.length == 3 ? SSData[0].trim() + "#" + SSData[1].trim() : BlankVal) + " </label></td>"
               + "<td><label for='Distributor' id='lblDistributor" + ind + "'> " + (DistriData.length == 3 ? DistriData[0].trim() + "#" + DistriData[1].trim() : BlankVal) + " </label></td>"
               + "<td><label for='IsInclude' id='lblIsInclude" + ind + "'> " + $('.chkIsInclude > input[type=checkbox]').prop('checked') + " </label></td>"
               + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:18px;' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
               + "<input type='hidden' id='hdnRegionID" + ind + "' name='hdnRegionID' value='" + (RegionData.length > 1 ? RegionData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnEmpGroupID" + ind + "' name='hdnEmpGroupID' value='" + (EmpGroupData.length > 0 ? EmpGroupID : 0) + "' />"
               + "<input type='hidden' id='hdnCustGroupID" + ind + "' name='hdnCustGroupID' value='" + (CustGroupData.length > 0 ? CustGroupID : 0) + "' />"
               + "<input type='hidden' id='hdnEmpID" + ind + "' name='hdnEmpID' value='" + (EmpData.length > 1 ? EmpData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnHrEmpID" + ind + "' name='hdnHrEmpID' value='" + (HierarchyEmpData.length > 1 ? HierarchyEmpData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnSSID" + ind + "' name='hdnSSID' value='" + (SSData.length == 3 ? SSData[2].trim() : 0) + "' />"
               + "<input type='hidden' id='hdnDistriID" + ind + "' name='hdnDistriID' value='" + (DistriData.length == 3 ? DistriData[2].trim() : 0) + "' />"
               + "</tr>"

            $('#tblConfig > tbody ').append(str);
            ClearConfigControls();
        }

        function btnSubmit_Click() {

            $("#btnSubmit").attr('disabled', 'disabled');

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
                $("#btnSubmit").removeAttr('disabled');
                return false;
            }
            var htmlEditorExtender = $('.ajax__html_editor_extender_texteditor');
            var msgbody = htmlEditorExtender.html();
          //  console.log(23)
          //  console.log(msgbody)
          //  console.log(23)
            var MessageID = 0;
            if (!$('.chkMode').is(':checked'))
                MessageID = $('.txtMessageCode').val().trim().split('-')[0].trim();
            
            var Headerobj = {
                MessageID: MessageID,
                IsAddMode: $('.chkMode').is(':checked'),
                Subject: $('.txtSubject').val(),
                ApplicableFor: $('.ddlAppliFor').val(),
                ApplicableFrom: $('.fromdate1').val(),
                ApplicableTo: $('.todate1').val(),
                MessageBody: msgbody, //$('.txtMessageBody').val(),
                IsActive: $('.chkActive').find('input').is(':checked')
            }

            $('.hidJsonInputHeader').val(JSON.stringify(Headerobj));
            var HeaderData = $('.hidJsonInputHeader').val();

            var TableData_Material = [];

            var totalItemcnt = 0;
            var IsError = false;
            var ErrorMsg = '';

            $('#tblConfig  > tbody > tr').each(function (row, tr) {
                totalItemcnt = 1;
                var RegionID = $("input[name='hdnRegionID']", this).val();
                var EmpGroupName = $("td > label[id^='lblEmpGroup']", this).text().trim();
                var EmpGroupID = $("input[name='hdnEmpGroupID']", this).val();
                var CustGroupName = $("td > label[id^='lblCustGroup']", this).text().trim();
                var CustGroupID = $("input[name='hdnCustGroupID']", this).val();
                var EmpID = $("input[name='hdnEmpID']", this).val();
                var HrEmpID = $("input[name='hdnHrEmpID']", this).val();
                var SSID = $("input[name='hdnSSID']", this).val();
                var DistriID = $("input[name='hdnDistriID']", this).val();
                var IsInclude = $("label[id^='lblIsInclude']", this).text().trim();

                if (EmpGroupName.length > 0 && (isNaN(parseInt(EmpGroupID)) || parseInt(EmpGroupID) == 0)) {
                    IsError = true;
                    ErrorMsg = 'EmpGroup Detail mission for : ' + EmpGroupName + ' . Please remove it and select again.'
                    return false;
                }

                if (CustGroupName.length > 0 && (isNaN(parseInt(CustGroupID)) || parseInt(CustGroupID) == 0)) {
                    IsError = true;
                    ErrorMsg = 'Customer Group Detail mission for : ' + EmpGroupName + ' . Please remove it and select again.'
                    return false;
                }

                var obj = {
                    RegionID: RegionID,
                    EmpGroupID: EmpGroupID,
                    CustGroupID: CustGroupID,
                    EmpID: EmpID,
                    HrEmpID: HrEmpID,
                    SSID: SSID,
                    DistriID: DistriID,
                    IsInclude: IsInclude,
                };

                TableData_Material.push(obj);
            });

            if (IsError) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg(ErrorMsg, 3);
                return false;
            }

            if ($('.ddlAppliFor').val() != 'D' && totalItemcnt == 0) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg('Please Add atleast one configuration', 3);
                return false;
            }

          
            
            console.log(343);
            console.log(htmlEditorExtender.html());
            $('.hidJsonInputMaterial').val(JSON.stringify(TableData_Material));
            var MaterialData = $('.hidJsonInputMaterial').val();
           
            if ($('.flCImageUpload')[0].files.length == 0 && $('.hdnImageHasValue').val() == "" &&  ($('#body_txtMessageBody').val().trim() == "&lt;br&gt;" || htmlEditorExtender.html() == "")) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg('Please add either Image or Message Body', 3);
                return false;
            }

            var formData = new FormData();
            formData.append('file', $('.flCImageUpload')[0].files[0]);

            var sv = $.ajax({
                url: 'MessageBroadCast.aspx/SaveData',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData }),
                contentType: 'application/json; charset=utf-8'

            });

            sv.success(function (result) {
                console.log(2434);
                console.log(result.d);
                if (result.d == "") {
                    $.unblockUI();
                    $("#btnSubmit").removeAttr('disabled');
                    return false;
                }
                else if (result.d.indexOf("ERROR=") >= 0) {
                    $.unblockUI();
                    $("#btnSubmit").removeAttr('disabled');
                    var ErrorMsg = result.d.split('=')[1].trim();
                    ModelMsg(ErrorMsg, 3);
                    return false;
                }
                if (result.d.indexOf("SUCCESS=") >= 0) {
                    var SuccessMsg = result.d.split('=')[1].trim();
                    var messageid = result.d.split(':')[1].trim();
                    // Save upload image
                    $.ajax({
                        type: 'post',
                        url: 'ImageHandler.ashx?messageid=' + messageid,
                        data: formData,
                        success: function (status) {
                            if (status != 'error') {
                                alert(SuccessMsg);
                                AppliForChange();
                                $.unblockUI();
                                location.reload(true);
                                return false;
                            }
                        },
                        processData: false,
                        contentType: false,
                        error: function () {
                            alert("Whoops something went wrong!");
                        }
                    });


                }
            });

            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg('Something is wrong...' + XMLHttpRequest.responseText, 3);
                return false;
            });



        }

        function GetMessageDetailByID(MessageID) {

            var sv = $.ajax({
                url: 'MessageBroadCast.aspx/GetMessageDetailByID',
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
                            console.log(result.d[i]['Body']);
                            var htmlEditorExtender = $('.ajax__html_editor_extender_texteditor');
                            htmlEditorExtender.html(result.d[i]['Body']);
                           
                            $('.txtSubject').val(result.d[i]['Subject']);
                            $('.fromdate1').val(result.d[i]['AppliFrom']);
                            $('.todate1').val(result.d[i]['AppliTo']);
                            $('.txtCreatedBy').val(result.d[i]['CreatedBy']);
                            $('.txtCreatedTime').val(result.d[i]['CreatedTime']);
                            $('.txtUpdatedBy').val(result.d[i]['UpdatedBy']);
                            $('.txtUpdatedTime').val(result.d[i]['UpdatedTime']);
                            //  $('.txtMessageBody').val(result.d[i]['Body']);
                           // $('#body_txtMessageBody').val(result.d[i]['Body'].html);
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

                            str = "<tr id='trMaterial" + ind + "'>"
                                  + "<td><label for='Region' id='lblRegion" + ind + "'>" + result.d[i]['Region'] + " </label></td>"
                                  + "<td><label for='HierarchyEmployee' id='lblHieEmployee" + ind + "'> " + result.d[i]['heirarchyEmp'] + " </label></td>"
                                + "<td><label for='EmpGroup' id='lblEmpGroup" + ind + "'> " + (result.d[i]['AppliFor'] == 'E' || result.d[i]['AppliFor'] == 'F' ? result.d[i]['EmpCustGroup'] : BlankVal) + " </label></td>"
                                + "<td><label for='Employee' id='lblEmployee" + ind + "'> " + (result.d[i]['AppliFor'] == 'E' || result.d[i]['AppliFor'] == 'F' ? result.d[i]['EmpCustName'] : BlankVal) + " </label></td>"
                                  + "<td><label for='CustGroup' id='lblCustGroup" + ind + "'> " + (result.d[i]['AppliFor'] == 'C' ? result.d[i]['EmpCustGroup'] : BlankVal) + " </label></td>"
                                  + "<td><label for='SS' id='lblSS" + ind + "'> " + (result.d[i]['AppliFor'] == 'C' && result.d[i]['UserType'] == '4' ? result.d[i]['EmpCustName'] : BlankVal) + " </label></td>"
                                  + "<td><label for='Distributor' id='lblDistributor" + ind + "'> " + (result.d[i]['AppliFor'] == 'C' && result.d[i]['UserType'] == '2' ? result.d[i]['EmpCustName'] : BlankVal) + " </label></td>"
                                  + "<td><label for='IsInclude' id='lblIsInclude" + ind + "'> " + result.d[i]['IsInclude'] + " </label></td>"
                                  + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:18px;' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
                                  + "<input type='hidden' id='hdnRegionID" + ind + "' name='hdnRegionID' value='" + result.d[i]['RegionID'] + "' />"
                                + "<input type='hidden' id='hdnEmpGroupID" + ind + "' name='hdnEmpGroupID' value='" + (result.d[i]['AppliFor'] == 'E' || result.d[i]['AppliFor'] == 'F' ? result.d[i]['EmpCustGroupID'] : 0) + "' />"
                                  + "<input type='hidden' id='hdnCustGroupID" + ind + "' name='hdnCustGroupID' value='" + (result.d[i]['AppliFor'] == 'C' ? result.d[i]['EmpCustGroupID'] : 0) + "' />"
                                + "<input type='hidden' id='hdnEmpID" + ind + "' name='hdnEmpID' value='" + (result.d[i]['AppliFor'] == 'E' || result.d[i]['AppliFor'] == 'F' ? result.d[i]['EmpCustID'] : 0) + "' />"
                                  + "<input type='hidden' id='hdnHrEmpID" + ind + "' name='hdnHrEmpID' value='" + result.d[i]['heirarchyEmpID'] + "' />"
                                  + "<input type='hidden' id='hdnSSID" + ind + "' name='hdnSSID' value='" + (result.d[i]['AppliFor'] == 'C' && result.d[i]['UserType'] == '4' ? result.d[i]['EmpCustID'] : 0) + "' />"
                                  + "<input type='hidden' id='hdnDistriID" + ind + "' name='hdnDistriID' value='" + (result.d[i]['AppliFor'] == 'C' && result.d[i]['UserType'] == '2' ? result.d[i]['EmpCustID'] : 0) + "' />"
                                  + "</tr>"

                            $('#tblConfig > tbody').append(str);
                            ClearConfigControls();
                        }
                    }

                }
            });

            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                $("#btnSubmit").removeAttr('disabled');
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
        }

    </script>

    <style>
        .table > tbody > tr > td > label {
            font-weight: normal;
        }

        .table > tbody > tr > td {
            padding: 5px 0px 0px 0px !IMPORTANT;
        }
    </style>

  
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" id="chkMode" tabindex="1" name="onoffswitch" class="chkMode _auchk" style="margin-bottom: 10px" onchange="ClearAllInputs();" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" checked="checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <%-- <div class="row">--%>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <asp:Label ID="lblApplicableFor" runat="server" Text="Message For" CssClass="input-group-addon"></asp:Label>
                    <select id="ddlAppliFor" runat="server" class="ddlAppliFor form-control" tabindex="2" onchange="AppliForChange();">
                        <option value="D" selected="selected">DMS Login</option>
                        <option value="C">Customer</option>
                        <option value="E">Employee / SFA</option>
                        <option value="F">Dealer App</option>
                    </select>
                </div>
            </div>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <asp:Label ID="lblMessageCode" runat="server" Text="Message Code" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtMessageCode" runat="server" TabIndex="3" CssClass="txtMessageCode form-control" autocomplete="off"></asp:TextBox>
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtMessageCode" runat="server" ServicePath="../Service.asmx"
                        UseContextKey="true" ServiceMethod="GetBroadcastMessage" MinimumPrefixLength="1" CompletionInterval="10"
                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMessageCode" OnClientPopulating="autoCompleteMessageCode_OnClientPopulating"
                        OnClientItemSelected="GetSelectedID">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <asp:Label ID="lblfromdate1" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtfromdate1" runat="server" MaxLength="10" TabIndex="4" onkeyup="return ValidateDate(this);" CssClass="fromdate1 form-control"></asp:TextBox>
                </div>
            </div>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <asp:Label ID="lbltodate1" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txttodate1" runat="server" TabIndex="5" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate1 form-control"></asp:TextBox>
                </div>
            </div>

            <div class="col-lg-9">
                <div class="input-group form-group">
                    <asp:Label ID="lblSubject" runat="server" Text="Subject" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtSubject" runat="server" CssClass="txtSubject form-control" TabIndex="6" MaxLength="200" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                </div>
            </div>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                </div>

            </div>
            <div class="col-lg-9">
                <div class="input-group form-group">
                    <asp:Label ID="lblMessageBody" runat="server" Text="Message Body" CssClass="input-group-addon"></asp:Label>
                    <asp:Label Text="(Up to 500 Char)" CssClass="input-group-addon" ></asp:Label>
                    <asp:TextBox ID="txtMessageBody" runat="server" Rows="3" TabIndex="7" TextMode="MultiLine" Height="200" CssClass="txtMessageBody form-control" MaxLength="500" data-bv-notempty="false" ></asp:TextBox>
                      <asp:HtmlEditorExtender ID="HtmlEditorExtender1" runat="server" TargetControlID="txtMessageBody" >
                     </asp:HtmlEditorExtender>
                     
                </div>
            </div>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                </div>
                <div class="input-group form-group">
                    <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                </div>
            </div>
            <div class="col-lg-12" style="padding: 0px">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="Label2" runat="server" Text="Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkActive" CssClass="chkActive form-control" runat="server" Checked="true" TabIndex="8" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:FileUpload ID="flCImageUpload" TabIndex="9" Style="width: 100%;" runat="server" CssClass="flCImageUpload form-control" accept=".png,.jpg,.jpeg,.gif,.pdf" onchange="CheckFile(this);" />
                        <input type="hidden" runat="server" id="hdnImageFile" class="hdnImageFile" />
                    </div>
                </div>
                <div class="col-lg-1">
                    <div class="input-group form-group" style="margin-left: 10px">
                        <img src="#" class="messageimg" style="display: none; max-width: 100%; max-height: 40px;" />
                        <input type="hidden" id="hdnImageHasValue" class="hdnImageHasValue" value="" />
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group" style="margin-left: 10px">
                        <input type="submit" name="btnSubmit" value="Save" id="btnSubmit" class="btnSubmit btn btn-success " onclick="btnSubmit_Click(); return false;" tabindex="19" />
                        <input type="button" name="btnClear" value="Clear" id="btnClear" style="margin-left: 10px" class="btnClear btn btn-danger" onclick="ClearAllInputs();" tabindex="20" />
                    </div>
                </div>

                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
            </div>

            <div class="col-lg-3 divRegion">
                <div class="input-group form-group">
                    <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="10"></asp:TextBox>
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                        ServiceMethod="GetStates" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                        TargetControlID="txtRegion" UseContextKey="True">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3 divEmpGroup">
                <div class="input-group form-group">
                    <asp:Label ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon" runat="server" />
                    <asp:TextBox runat="server" ID="txtEmpGroup" CssClass="txtEmpGroup form-control" Style="background-color: rgb(250, 255, 189);" TabIndex="11" />
                    <asp:AutoCompleteExtender ID="aceEmpGroup" runat="server" TargetControlID="txtEmpGroup" ServiceMethod="GetEmployeeGroupName" ServicePath="~/WebService.asmx"
                        OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                        MinimumPrefixLength="1" UseContextKey="true">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3 divHierarchyEmp">
                <div class="input-group form-group">
                    <asp:Label ID="lblHierarchyCode" runat="server" Text="Hierarchy Employee" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtHrEmpCode" runat="server" CssClass="txtHrEmpCode form-control" TabIndex="12" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceHierarchyEmp" runat="server" ServicePath="../Service.asmx"
                        UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtHrEmpCode">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3 divEmp">
                <div class="input-group form-group">
                    <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtEmpCode" runat="server" CssClass="form-control txtEmpCode" TabIndex="13" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                        UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmpCode">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3 divCustGroup">
                <div class="input-group form-group">
                    <asp:Label ID="lblCustGroup" Text="Customer Group" CssClass="input-group-addon" runat="server" />
                    <asp:TextBox runat="server" ID="txtCustGroup" CssClass="txtCustGroup form-control" Style="background-color: rgb(250, 255, 189);" TabIndex="14" />
                    <asp:AutoCompleteExtender ID="aceCustGroup" runat="server" TargetControlID="txtCustGroup" ServiceMethod="GetCustomerGroupNameDesc" ServicePath="~/WebService.asmx"
                        OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                        MinimumPrefixLength="1" UseContextKey="true">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
             <%-- <div class="col-lg-3 divEmpGroupCode">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="Label1" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" AutoPostBack="false" CssClass="ddlEGroup form-control"   data-bv-callback-message="Select Value" 
                            DataTextField="EmpGroupName" DataValueField="EmpGroupID" TabIndex="1">
                           
                        </asp:DropDownList>

                    </div>
                </div>--%>



            <div class="col-lg-3 divSS">
                <div class="input-group form-group">
                    <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtSSCode" runat="server" TabIndex="15" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control"></asp:TextBox>
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                        UseContextKey="true" ServiceMethod="GetSSFromPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3 divDist">
                <div class="input-group form-group divDistributor" id="divDistributor" runat="server">
                    <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtDistCode" runat="server" TabIndex="16" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                        UseContextKey="true" ServiceMethod="GetDistFromSSPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                    </asp:AutoCompleteExtender>
                </div>
            </div>
            <div class="col-lg-3 divIsInclude">
                <div class="input-group form-group">
                    <asp:Label ID="lblIsInclude" Text="Is Include" runat="server" CssClass="input-group-addon" />
                    <asp:CheckBox ID="chkIsInclude" CssClass="chkIsInclude form-control" runat="server" Checked="true" TabIndex="17" />
                </div>
            </div>
            <div class="col-lg-3">
                <div class="input-group form-group">
                    <input type="button" value="Add Configuration" id="btnAddConfig" name="btnAddConfig" tabindex="18" class="btnAddConfig btn btn-info" onclick="AddMoreRowMaterial();" />
                    <input type="hidden" id="CountRowMaterial" />
                    <input type="hidden" id="hidJsonInputMaterial" class="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                    <input type="hidden" id="hidJsonInputHeader" class="hidJsonInputHeader" name="hidJsonInputHeader" value="" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12" style="max-height: 34vh; overflow-y: auto;">
                    <table id="tblConfig" class="tblConfig table" border="1" style="width: 98%; border-collapse: collapse; font-size: 11px; margin-top: 0px; margin-bottom: 0px; margin-left: 10px">
                        <thead>
                            <tr class="table-header-gradient" style="margin-left: 2px">
                                <th style="width: 10%;">Region</th>
                                <th style="width: 12%">Hierarchy Emp.</th>
                                <th style="width: 12%">Emp. Group</th>
                                <th style="width: 12%;">Emp.</th>
                                <th style="width: 10%">Cust. Group</th>
                                <th style="width: 16%">SS</th>
                                <th style="width: 16%">Distributor</th>
                                <th style="width: 4%">Is Inc</th>
                                <th style="width: 3%">Del</th>
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
