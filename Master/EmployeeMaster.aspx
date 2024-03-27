<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="EmployeeMaster.aspx.cs" Inherits="Master_EmployeeMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
            $('.accountForm')
                .bootstrapValidator({
                    // Only disabled elements are excluded
                    // The invisible elements belonging to inactive tabs must be validated
                    excluded: [':disabled'],
                    feedbackIcons: {
                        valid: 'glyphicon glyphicon-ok',
                        invalid: 'glyphicon glyphicon-remove',
                        validating: 'glyphicon glyphicon-refresh'
                    },
                    live: 'enabled',
                    trigger: null
                })
                // Called when a field is invalid
                .on('error.field.bv', function (e, data) {
                    // data.element --> The field element
                    // alert('errr');
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id');

                    $('a[href="#' + tabId + '"][data-toggle="tab"]')
                        .parent()
                        .find('i')
                        .removeClass('fa-check')
                        .addClass('fa-times');
                })
                // Called when a field is valid
                .on('success.field.bv', function (e, data) {
                    // data.bv      --> The BootstrapValidator instance
                    // data.element --> The field element
                    //alert(data.element.parents('.tab-pane'));
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id'),
                        $icon = $('a[href="#' + tabId + '"][data-toggle="tab"]')
                                    .parent()
                                    .find('i')
                                    .removeClass('fa-check fa-times');

                    // Check if the submit button is clicked
                    if (data.bv.getSubmitButton()) {
                        // Check if all fields in tab are valid

                        var isValidTab = data.bv.isValidContainer($tabPane);
                        $icon.addClass(isValidTab ? 'fa-check' : 'fa-times');
                    }
                });
        }

        function Relaod() {

            $('.ShowPassword').hover(function show() {
                //Change the attribute to text  
                $('.txtPassword').attr('type', 'text');
                $('.icon').removeClass('glyphicon glyphicon-eye-close').addClass('glyphicon glyphicon-eye-open');
            },
             function () {
                 //Change the attribute back to password  
                 $('.txtPassword').attr('type', 'password');
                 $('.icon').removeClass('glyphicon glyphicon-eye-open').addClass('glyphicon glyphicon-eye-close');
             });

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });
            $('.accdatepick').attr('data-bv-date', 'true');
            $('.accdatepick').attr('data-bv-date-format', 'DD/MM/YYYY');
            $('.accdatepick').datepicker({
                dateFormat: 'dd/mm/yy', changeMonth: true, changeYear: true, onSelect: function (selected) {
                    $('.accountForm').data('bootstrapValidator').revalidateField($(this));
                }
            });

            $('.accfromdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                onSelect: function (selected) {
                    $('.todate').datepicker("option", "minDate", selected);
                    $('.accountForm').data('bootstrapValidator').revalidateField($(this));
                }
            });

            $('.acctodate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                onSelect: function (selected) {
                    $('.fromdate').datepicker("option", "maxDate", selected);
                    $('.accountForm').data('bootstrapValidator').revalidateField($(this));
                }
            })
            $('.accountForm')
                .bootstrapValidator({
                    // Only disabled elements are excluded
                    // The invisible elements belonging to inactive tabs must be validated
                    excluded: [':disabled'],
                    feedbackIcons: {
                        valid: 'glyphicon glyphicon-ok',
                        invalid: 'glyphicon glyphicon-remove',
                        validating: 'glyphicon glyphicon-refresh'
                    },
                    live: 'enabled',
                    trigger: null
                })
                // Called when a field is invalid
                .on('error.field.bv', function (e, data) {
                    // data.element --> The field element
                    // alert('errr');
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id');

                    $('a[href="#' + tabId + '"][data-toggle="tab"]')
                        .parent()
                        .find('i')
                        .removeClass('fa-check')
                        .addClass('fa-times');
                })
                // Called when a field is valid
                .on('success.field.bv', function (e, data) {
                    // data.bv      --> The BootstrapValidator instance
                    // data.element --> The field element
                    //alert(data.element.parents('.tab-pane'));
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id'),
                        $icon = $('a[href="#' + tabId + '"][data-toggle="tab"]')
                                    .parent()
                                    .find('i')
                                    .removeClass('fa-check fa-times');

                    // Check if the submit button is clicked
                    if (data.bv.getSubmitButton()) {
                        // Check if all fields in tab are valid

                        var isValidTab = data.bv.isValidContainer($tabPane);
                        $icon.addClass(isValidTab ? 'fa-check' : 'fa-times');
                    }
                });
            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("EmployeeMaster", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("EmployeeMaster") + '"]').tab('show');
        }

        function SetActiveTab(index) {
            $.cookie('Employee', index);
            Relaod();
        }

        function _btnCheck() {
            if (!$('.accountForm').data('bootstrapValidator').isValid())
                $('.accountForm').bootstrapValidator('validate');

            return $('.accountForm').data('bootstrapValidator').isValid();
        }

        function onAutoCompleteSelected(sender, e) {

            __doPostBack(sender.get_element().name, null);
        }

        function onCityAutoCompleteSelected(sender, e) {

            __doPostBack(sender.get_element().name, null);
        }

        //function removeReadonly() {
        //    $('#body_txtLoginName').attr("readonly", false);
        //    $('#body_txtPassword').attr("readonly", false);
        //}

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body accountForm">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnTextChanged="txtCode_TextChanged" CssClass="form-control" Enabled="false" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployee" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="onAutoCompleteSelected"
                            Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab" data-toggle="tab">Address</a></li>
                <li style="display: none;"><a href="#tabs-3" role="tab" data-toggle="tab">Account</a></li>
                <li><a href="#tabs-4" role="tab" data-toggle="tab">HR</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblBranch" runat="server" Text="Branch" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlBranch" AppendDataBoundItems="true" DataSourceID="edsBranch"
                                    DataTextField="Branch" DataValueField="BranchID" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Text="---Select---" Value="0" />
                                </asp:DropDownList>
                                <asp:Label ID="Label4" runat="server" Text="User Type" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlUserType" runat="server" CssClass="form-control" data-bv-notempty="true">
                                    <asp:ListItem Value="" Text="---Select---"></asp:ListItem>
                                    <asp:ListItem Value="d" Text="DMS"></asp:ListItem>
                                    <asp:ListItem Value="m" Text="RSD"></asp:ListItem>
                                    <asp:ListItem Value="b" Text="Both"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsBranch" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.CustomerID = @ParentID" DefaultContainerName="DDMSEntities"
                                    EnableFlattening="False" EntitySetName="CRD1">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>


                            </div>


                            <div class="input-group form-group">
                                <asp:Label ID="lblWorkPhone" runat="server" Text="Work Phone" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtWorkPhone" runat="server" placeholder="Work Phone"
                                    onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                <asp:TextBox ID="txtExtension" runat="server" placeholder="Ext" Style="display: none"
                                    onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblWorkEmail" runat="server" Text="Work E-Mail" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtWorkEmail" runat="server" placeholder="someone@example.com" CssClass="form-control" data-bv-emailaddress="true"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text="Traceability (Minute)" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtTraceInterval" runat="server" data-bv-stringlength="false" MaxLength="3" placeholder="Traceability (Minute)"
                                    onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                <asp:Label ID="lblIsDMS" runat="server" Text="Is DMS" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsDMS" runat="server" Checked="false" CssClass="form-control" Enabled="false"></asp:CheckBox>
                            </div>
                            <div class="input-group form-group" style="display: none">
                                <asp:Label ID="lblIsDiscount" runat="server" Text="Discount(Min - Max)% " CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="10%">
                                            <asp:CheckBox ID="chkIsDiscount" runat="server" CssClass="form-control"></asp:CheckBox>
                                        </td>
                                        <td width="45%">
                                            <asp:TextBox ID="txtMinDis" runat="server" data-bv-stringlength="false" MaxLength="10" placeholder="Min Discount" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>

                                        </td>
                                        <td width="45%">
                                            <asp:TextBox ID="txtMaxDis" runat="server" placeholder="Max Discount" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>

                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblMobile" runat="server" Text="Mobile - Home" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtMobile" runat="server" data-bv-stringlength="false" MaxLength="10" placeholder="Mobile"
                                                onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtHomePhone" runat="server" placeholder="Home"
                                                onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblPersonnelEmail" runat="server" Text="Personal E-Mail" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtPersonnelEmail" runat="server" CssClass="form-control" data-bv-emailaddress="true"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblIsActive" runat="server" Text="DMS Is Active" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-control" />
                                <asp:Label ID="lblIsSAPActive" runat="server" Text="SAP Is Active" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsSAPActive" Enabled="false" runat="server" Checked="true" CssClass="form-control" />
                                <asp:Label ID="lblGender" runat="server" Text="Gender" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Text="---Select Gender---" Value="0" />
                                    <asp:ListItem Text="Male" Value="M" />
                                    <asp:ListItem Text="Female" Value="F" />
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCMobile" runat="server" Text="Clear Registration" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkMobile" runat="server" Checked="false" CssClass="form-control"></asp:CheckBox>
                                <asp:Label ID="lblCIsAprrover" runat="server" Text="Is Approver" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsApprover" runat="server" Checked="false" CssClass="form-control"></asp:CheckBox>
                                <asp:Label ID="lblIsAdmin" runat="server" Text="Is Admin" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsAdmin" runat="server" Checked="false" CssClass="form-control"></asp:CheckBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12 _textArea">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDescription" runat="server" Text="Notes" CssClass="lbl_desc input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>


                    <div class="row">
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreatedBy" runat="server" Text="Sync / Created By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreatedTime" runat="server" Text="Sync / Created Time" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-2" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTypeAddress" runat="server" Text="Type" Visible="false" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlTypeAddress" runat="server" Visible="false" CssClass="form-control">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                    <asp:ListItem Value="T" Text="Temporary"></asp:ListItem>
                                    <asp:ListItem Value="P" Text="Permanent"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:Label ID="lblblock" runat="server" Text="Block" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtblock" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblStreet" runat="server" Text="Street" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtStreet" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblLocation" runat="server" Text="Location" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCity" runat="server" Text="City - Pincode" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtCity" runat="server" CssClass="txtCustCode form-control" OnTextChanged="txtCity_TextChanged"></asp:TextBox>
                                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCityName" runat="server" ServicePath="~/Service.asmx"
                                                UseContextKey="true" ServiceMethod="GetCitys" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="onCityAutoCompleteSelected"
                                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                                            </asp:AutoCompleteExtender>
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtPinCode" runat="server" MaxLength="6" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtState" CssClass="form-control" runat="server" autocomplete="off" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCountry" runat="server" Text="Country" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCountry" CssClass="form-control" runat="server" autocomplete="off" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblContactPerson" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblMobileAddress" runat="server" Text="Mobile - Phone" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtMobileAddress" runat="server" placeholder="Mobile"
                                                onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtPhoneAddress" runat="server" placeholder="Phone"
                                                onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-3" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDescriptionAccount" runat="server" Text="Description" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDescriptionAccount" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblPaymentMode" runat="server" Text="Payment Mode" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                    <asp:ListItem Value="C" Text="Cash"></asp:ListItem>
                                    <asp:ListItem Value="Q" Text="Cheque"></asp:ListItem>
                                    <asp:ListItem Value="B" Text="Bank Transfer"></asp:ListItem>
                                    <asp:ListItem Text="Credit Note" Value="N"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblBankName" runat="server" Text="Bank Name - Code" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtBankName" runat="server" placeholder="Bank Name" CssClass="form-control"></asp:TextBox>
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtBranchCode" runat="server" placeholder="Branch Code" CssClass="form-control"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblPanNumber" runat="server" Text="PAN Number - Salary" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtPanNumber" runat="server" CssClass="form-control" placeholder="Pan Number"></asp:TextBox>
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtSalary" runat="server" CssClass="form-control" placeholder="Salary" onkeypress="return isNumberKey(event);" onpaste="return false;"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-4" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTypeHR" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlTYpeHR" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                    <asp:ListItem Value="T" Text="Temporary"></asp:ListItem>
                                    <asp:ListItem Value="P" Text="Permanent"></asp:ListItem>
                                    <asp:ListItem Value="C" Text="Contract"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblGroup" runat="server" Text="Group" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlGroup" runat="server" CssClass="form-control" DataSourceID="edsddlGroupHR" DataTextField="NewName"
                                    DataValueField="EmpGroupID" AppendDataBoundItems="true" data-bv-callback="true"
                                    data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlGroupHR" runat="server" ConnectionString="name=DDMSEntities" Where="it.Active = true and it.ParentID = @ParentID"
                                    Select="it.[EmpGroupID], it.[EmpGroupName] + ' # ' + it.[EmpGroupDesc] as NewName" DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OGRPs">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblManager" runat="server" Text="Manager" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtManager" TabIndex="1" runat="server" MaxLength="200" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtManagerCode" runat="server" ServicePath="../WebService.asmx"
                                    UseContextKey="true" ServiceMethod="GetEmployee" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtManager">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblFieldStaffManager" runat="server" Text="Field Staff Manager" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtFieldStaffManager" TabIndex="1" runat="server" MaxLength="200" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtFieldStaffManagerCode" runat="server" ServicePath="../WebService.asmx"
                                    UseContextKey="true" ServiceMethod="GetEmployee" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtFieldStaffManager">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblJoiningDate" runat="server" Text="Joining Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtJoiningDate" runat="server" CssClass="accdatepick form-control" onfocus="this.blur();"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblEducation" runat="server" Text="Education" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtEducation" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="Label2" runat="server" Text="HeadQuarter" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtHeadQuarter" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                            </div>
                            <div class="input-group form-group" style="display: none;">
                                <asp:Label ID="Label3" runat="server" Text="Certificate" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCertificate" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUserName" runat="server" Text="User Name" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtLoginName" CssClass="form-control" runat="server" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblPassword" runat="server" Text="Password" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="txtPassword form-control" TextMode="Password" autocomplete="new-password"></asp:TextBox>
                                <a id="ShowPassword" class="ShowPassword input-group-addon"><span class="icon glyphicon glyphicon-eye-close"></span></a>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblSecQue" runat="server" Text="Security Question" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlSecQue" runat="server" CssClass="form-control" AppendDataBoundItems="true" DataTextField="QuesName" DataValueField="QuesID" DataSourceID="edsQues">
                                    <asp:ListItem Text="---Select---" Value="0" />
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsQues" runat="server" ConnectionString="name=DDMSEntities" Where="it.DocType like 'S' and it.Active = true and it.ParentID = @ParentID"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OQUS">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblSecAns" runat="server" Text="Security Answer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtSecAns" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblLicenceNumber" runat="server" Text="Licence No. - Expiry" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtLicenceNumber" runat="server" placeholder="License Number" CssClass="form-control"></asp:TextBox>
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtExpiryDate" runat="server" placeholder="Expiry" onfocus="this.blur();" CssClass="accdatepick form-control"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <div class="input-group form-group">
                                <asp:Label ID="lblHomeRadius" runat="server" Text="Home Radius (Meter)" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtHomeRadius" runat="server" CssClass="form-control" onkeypress="return isNumberKeyForAmount(event);" MaxLength="10"></asp:TextBox>
                            </div>

                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12 _textArea">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTerms" runat="server" Text="Terms & Conditions" CssClass="lbl_desc input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtTermsConditions" runat="server" placeholder="Terms & Conditions" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" CssClass="btn btn-default" ValidationGroup="RouteCode" runat="server"
                Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false" runat="server"
                Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>
</asp:Content>
