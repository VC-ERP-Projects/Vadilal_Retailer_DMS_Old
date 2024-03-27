<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CouponMaster.aspx.cs" Inherits="Master_CouponMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="../Scripts/jquery.mask.js"></script>

    <script type="text/javascript">
        function _btnCheck() {
            var flag = CheckStartEndDate();
            if (flag == false) {
                return false;
            }

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function ChangeState()
        {
            $('.txtCity').val('');
            $('.txtPinCode').val('');
        }

        function ChangeCity() {
            $('.txtPinCode').val('');
        }

        function CheckFields()
        {
            var state = $('.txtState').val().trim();
            var city = $('.txtCity').val().trim();
            var pin = $('.txtPinCode').val().trim();

            if(state == "" && city == "" && pin == "")
            {
                ModelMsg("Please enter atleast one field value.", 3);
                event.preventDefault();
                return false;
            }
        }

        function acettxtCity_OnClientPopulating(sender, args) {
            var key = 0;
            var state = $('.txtState').val();
            if (state != "") {
                var valSt = state.split('-');
                if (valSt.length == 2)
                {
                    key = valSt[0].trim();
                }
                sender.set_contextKey(key);
            }
        }

        function acettxtPinCode_OnClientPopulating(sender, args)
        {
            var key = '0';
            var state = $('.txtState').val();
            if (state != "") {
                var statelen = state.split('-');
                if (statelen.length == 2)
                {
                    key = statelen[0].trim();
                }
                else
                {
                    key = 0;
                }
            }
            var city = $('.txtCity').val();
            if(city != "")
            {
                var citylen = city.split('-');
                if (citylen.length == 2) {
                    key += '#' + citylen[0].trim();
                }
                else
                {
                    key += '#0';
                }
            }
            sender.set_contextKey(key);
        }

        function CheckStartEndDate() {
            var start = $('.txtStartDate').val();
            var expire = $('.txtExpireDate').val();

            if (start != '' && expire != '') {
                var parts = start.split('/');
                var st = new Date(parts[2], parts[1] - 1, parts[0]);
                var parts1 = expire.split('/');
                var end = new Date(parts1[2], parts1[1] - 1, parts1[0]);

                if (st > end) {
                    ModelMsg("Startdate should not be greater than Expiredate.", 3);
                    event.preventDefault();
                    return false;
                }
            }
            else
                return true;
        }

        // Date Validation Function 
        function ValidateDate(txt) {
            var txtVal = $(txt).val();

            if (txtVal == "") {
                return true;
            }

            var rxDatePattern = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/; //Declare Regex
            var dtArray = txtVal.match(rxDatePattern); // is format OK?

            if (dtArray == null) {
                ModelMsg("Please enter proper date in dd/mm/yyyy format", 3);
                var today = new Date();

                var mon = today.getMonth() + 1;
                var mydt = today.getDate();
                if (mydt < 10) {
                    mydt = "0" + mydt;
                }
                if (mon < 10) {
                    mon = "0" + mon;
                }

                $(txt).val(mydt + "/" + mon + "/" + today.getFullYear());
                event.preventDefault();
                return false;
            }
            else {
                return true;
            }
        }

        function CheckTime(txt) {
            var tm = $(txt).val();
            if (tm != "") {
                var arr = tm.split(':');
                if (arr.length != 3) {
                    ModelMsg("Please enter proper time in hh:mm:ss format", 3);
                    $(txt).val('');
                    event.preventDefault();
                    return false;
                }
                var hr = parseInt(arr[0]);

                var min = 0;
                if (arr[1] != "") {
                    min = parseInt(arr[1]);
                }
                var sec = 0;
                if (arr[2] != "") {
                    sec = parseInt(arr[2]);
                }
                if (hr >= 24) {
                    ModelMsg("Please enter proper time in hh:mm:ss format", 3);
                    $(txt).val('');
                    $(txt).focus();
                    event.preventDefault();
                    return false;
                }
                if (min >= 60) {
                    ModelMsg("Please enter proper time in hh:mm:ss format", 3);
                    $(txt).val('');
                    $(txt).focus();
                    event.preventDefault();
                    return false;
                }
                if (sec >= 60) {
                    ModelMsg("Please enter proper time in hh:mm:ss format", 3);
                    $(txt).val('');
                    $(txt).focus();
                    event.preventDefault();
                    return false;
                }
            }

        }

        function CheckPercentage(txt) {
            if ($(txt).val() != '') {
                var perct = parseFloat($(txt).val());
                var ddlVal = $('.ddlDiscount').val();

                if (ddlVal == 'P') {
                    if (perct > 100.00) {
                        ModelMsg("Please enter Percentage less than 100%.", 3);
                        $(txt).val('');
                        $(txt).focus();
                        event.preventDefault();
                        return false;
                    }
                }
            }
        }

        $(document).ready(function () {

            $('.txtStartTime').mask('00:00:00', { placeholder: "__:__:__" });
            $('.txtExpireTime').mask('00:00:00', { placeholder: "__:__:__" });
        });

        function CheckMultipleUse() {

            if ($('.chkMultipleUse').find('input').is(':checked')) {
                $('.txtMaxNoUseable').removeAttr('disabled');
            }
            else {
                $('.txtMaxNoUseable').attr('disabled', 'disabled');
            }
        }

        //function DisplayDiv()
        //{
        //    if ($('.chkApplyToAll').find('input').is(':checked')) {
        //        $('#DivCoupen').hide();
        //    }
        //    else
        //    {
        //        $('#DivCoupen').show();
        //    }
        //}

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Coupon Code" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtCouponCode" AutoPostBack="true" OnTextChanged="txtCouponCode_TextChanged" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCouponCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCouponCodes" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="true" CompletionSetCount="1" TargetControlID="txtCouponCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Coupon Name" ID="lblCouponName" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtCouponName" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>

                    <div class="input-group form-group">
                        <asp:Label Text="Start Date-Time" runat="server" CssClass="input-group-addon" />
                        <table width="100%">
                            <tr>
                                <td width="50%">
                                    <asp:TextBox runat="server" ID="txtStartDate" onkeyup="return ValidateDate(this);" CssClass="txtStartDate datepick form-control" />
                                </td>
                                <td width="50%">
                                    <asp:TextBox runat="server" ID="txtStartTime" CssClass="txtStartTime form-control" MaxLength="8" onblur="CheckTime(this);" />
                                </td>
                            </tr>
                        </table>

                    </div>

                    <div class="input-group form-group">
                        <asp:Label Text="Expire Date-Time" runat="server" CssClass="input-group-addon" />
                        <table width="100%">
                            <tr>
                                <td width="50%">
                                    <asp:TextBox runat="server" ID="txtExpireDate" onkeyup="return ValidateDate(this);" CssClass="txtExpireDate datepick form-control" />
                                </td>
                                <td width="50%">
                                    <asp:TextBox runat="server" ID="txtExpireTime" CssClass="txtExpireTime form-control" MaxLength="8" onblur="CheckTime(this);" />
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div class="input-group form-group">
                        <asp:Label Text="Discount" runat="server" CssClass="input-group-addon" />
                        <table width="100%">
                            <tr>
                                <td width="50%">
                                    <asp:DropDownList ID="ddlDiscount" runat="server" CssClass="ddlDiscount form-control">
                                        <asp:ListItem Text="Flat Amount" Value="A"></asp:ListItem>
                                        <asp:ListItem Text="Percentage" Value="P"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td width="50%">
                                    <asp:TextBox runat="server" ID="txtDiscount" MaxLength="6" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" CssClass="txtDiscount form-control" onblur="CheckPercentage(this);" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                                </td>
                            </tr>
                        </table>
                    </div>

                </div>
                <div class="col-lg-4">

                    <div class="input-group form-group">
                        <asp:Label Text="Allow Multiple Use" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBox ID="chkMultipleUse" runat="server" CssClass="chkMultipleUse form-control" onchange="CheckMultipleUse();" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Maximum No. of Use" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtMaxNoUseable" MaxLength="10" Enabled="false" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="txtMaxNoUseable form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Total No.of Use" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTotalNoUseable" MaxLength="10" onkeypress="return isNumberKey(event);" onpaste="return false;" Enabled="false" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="New User" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBox ID="chkNewUser" runat="server" CssClass="form-control" />
                    </div>

                    <div class="input-group form-group">
                        <asp:Label Text="Send Notification" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBox ID="chkNotify" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Active" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBox ID="chkActive" runat="server" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Minimum Bill Value" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtMinBillValue" MaxLength="10" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" CssClass="txtMinBillValue form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Maximum Bill Value" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtMaxBillValue" MaxLength="10" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" CssClass="txtMaxBillValue form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Apply to All" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBox ID="chkApplyToAll" runat="server" CssClass="chkApplyToAll form-control" Checked="true" />
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label Text="Message" ID="lblDesc" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDesc" TextMode="MultiLine" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="DivCoupen" >
        <div class="panel panel-default" style="max-height: 120px;">
            <div class="panel-body">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label Text="State" ID="lblState" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtState" CssClass="txtState form-control" onchange="ChangeState();"  />
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtState" runat="server" ServicePath="../WebService.asmx" UseContextKey="true" ServiceMethod="GetStateNames" MinimumPrefixLength="1"
                                CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtState">
                            </asp:AutoCompleteExtender>
                        </div>
                         <div class="input-group form-group">
                            <asp:Button ID="btnAdd" runat="server" Text="Add" OnClick="btnAdd_Click" OnClientClick="CheckFields();" CssClass="btn btn-default" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label Text="City" ID="lblCity" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtCity" CssClass="txtCity form-control" onchange="ChangeCity();"/>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCity" runat="server" OnClientPopulating="acettxtCity_OnClientPopulating"  ServicePath="../WebService.asmx" UseContextKey="true" ServiceMethod="GetCityNames" MinimumPrefixLength="1"
                                CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label Text="Pincode" ID="lblPincode" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtPinCode" CssClass="txtPinCode form-control" />
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtpincode" runat="server" ServicePath="../WebService.asmx" OnClientPopulating="acettxtPinCode_OnClientPopulating" UseContextKey="true" ServiceMethod="GetPinCodesByCriteria" MinimumPrefixLength="1"
                                CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPinCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>

                </div>
            </div>
        </div>
        <div>
            <asp:GridView runat="server" ID="gvCoupen" ClientIDMode="Static" CssClass="table" HeaderStyle-CssClass="table-header-gradient" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnRowCommand="gvCoupen_RowCommand" EmptyDataText="No Record Found.">
                <Columns>
                    <asp:TemplateField HeaderText="No.">
                        <ItemTemplate>
                            <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                        </ItemTemplate>
                         <HeaderStyle Width="8%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="State">
                        <ItemTemplate>
                            <asp:Label ID="lblState" runat="server" Text='<%# Bind("OCST.StateName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="City">
                        <ItemTemplate>
                            <asp:Label ID="lblCity" runat="server" Text='<%# Bind("OCTY.CityName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="PinCode">
                        <ItemTemplate>
                            <asp:Label ID="lblPinCode" runat="server" Text='<%# Bind("OPIN.PinCodeID") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Area">
                        <ItemTemplate>
                            <asp:Label ID="lblArea" runat="server" Text='<%# Bind("OPIN.Area") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Edit">
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkEdit" Text="Edit" CommandName="EditMode" CommandArgument='<%# Container.DataItemIndex %>' runat="server" ></asp:LinkButton>
                        </ItemTemplate>
                         <HeaderStyle Width="8%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Delete">
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkDelete" Text="Delete" runat="server" CommandName="DeleteMode" CommandArgument='<%# Container.DataItemIndex %>'
                                OnClientClick="return confirm('Are sure you want delete this?');"></asp:LinkButton>
                        </ItemTemplate>
                         <HeaderStyle Width="8%" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
    <asp:Button Text="Submit" ID="btnSubmit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" runat="server" OnClick="btnSubmit_Click" />
    <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" runat="server" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
</asp:Content>


