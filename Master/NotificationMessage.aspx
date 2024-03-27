<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="NotificationMessage.aspx.cs" Inherits="Master_NotificationMessage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="../Scripts/jquery.mask.js"></script>

    <script type="text/javascript">
        function _btnCheck() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function DisplayCoupon() {
            $('.txtCouponCode').val('');
            $('.txtCouponCode').show();
        }

        function ChangeCity() {
            $('.txtPinCode').val('');
        }

        function HideShowDIV() {
            var type = $('.ddlType').val();
            $('.txtCouponCode').val('');
            $('.txtDesc').val('');
            $('.txtSubject').val('');

            if (type == "Coupon") {
                $('.txtCouponCode').show();
            }
            else {
                $('.txtCouponCode').hide();
            }
        }

        function acePinCode_OnClientPopulating(sender, args) {
            var key = '0';
          
            var city = $('.ddlCity').val();
            if (city != "") {
                key += '#' + city;
            } else {
                key += '#0';
            }

            sender.set_contextKey(key);
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:label text="Notification Type" runat="server" cssclass="input-group-addon" />

                        <table width="100%">
                            <tr>
                                <td style="width: 50%;">
                                    <asp:dropdownlist id="ddlType" cssclass="ddlType form-control" runat="server" onchange="HideShowDIV();">
                                        <asp:ListItem>General</asp:ListItem>
                                        <asp:ListItem>Coupon</asp:ListItem>
                                    </asp:dropdownlist>
                                </td>
                                <td style="width: 50%;">
                                    <asp:textbox runat="server" id="txtCouponCode" autopostback="true" ontextchanged="txtCouponCode_TextChanged" cssclass="txtCouponCode form-control" style="display: none;" />
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" id="acettxtCouponCode" runat="server" servicepath="../WebService.asmx"
                                        usecontextkey="true" servicemethod="GetCouponCodes" minimumprefixlength="1" completioninterval="10"
                                        enablecaching="true" completionsetcount="1" targetcontrolid="txtCouponCode">
                                    </asp:autocompleteextender>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div class="input-group form-group">
                        <asp:label text="Subject" id="lblSubject" runat="server" cssclass="input-group-addon" />
                        <asp:textbox runat="server" id="txtSubject" cssclass="txtSubject form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>

                    <div class="input-group form-group">
                        <asp:label text="Message" id="lblDesc" runat="server" cssclass="input-group-addon" />
                        <asp:textbox runat="server" id="txtDesc" textmode="MultiLine" rows="5" cssclass="txtDesc form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:label id="lblCustGroup" runat="server" text="Customer Group" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist id="ddlGroup" runat="server" datasourceid="edsddlGroup" datatextfield="CustGroupName" cssclass="form-control" datavaluefield="CustGroupID">
                        </asp:dropdownlist>
                        <asp:entitydatasource id="edsddlGroup" runat="server" connectionstring="name=DDMSEntities"
                            defaultcontainername="DDMSEntities" enableflattening="False" entitysetname="CGRPs">
                        </asp:entitydatasource>
                    </div>

                    <div class="input-group form-group">
                        <asp:label id="lblCity" runat="server" text="City" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist id="ddlCity" runat="server" appenddatabounditems="True" cssclass="ddlCity form-control"
                            datasourceid="edsCity" datatextfield="CityName" datavaluefield="CityID" onchange="ChangeCity();">
                                <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                            </asp:dropdownlist>
                        <asp:entitydatasource id="edsCity" runat="server" connectionstring="name=DDMSEntities"
                            defaultcontainername="DDMSEntities" enableflattening="False" orderby="it.CityName" entitysetname="OCTies">
                            </asp:entitydatasource>
                    </div>

                    <div class="input-group form-group">
                        <asp:label id="lblPinCode" runat="server" text="PinCode" cssclass="input-group-addon"></asp:label>
                        <asp:textbox runat="server" id="txtPinCode" cssclass="txtPinCode form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acePinCode" runat="server" ServicePath="../WebService.asmx" OnClientPopulating="acePinCode_OnClientPopulating" UseContextKey="true" ServiceMethod="GetPinCodesByCriteria" MinimumPrefixLength="1"
                                CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPinCode">
                            </asp:AutoCompleteExtender>
                        
                    </div>
                </div>

            </div>
        </div>
    </div>

    <asp:button text="Submit" id="btnSubmit" cssclass="btn btn-default" onclientclick="return _btnCheck();" runat="server" onclick="btnSubmit_Click" />
    <asp:button text="Cancel" id="btnCancel" cssclass="btn btn-default" runat="server" onclick="btnCancel_Click" usesubmitbehavior="false" causesvalidation="false" />
</asp:Content>


