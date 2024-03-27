<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="HelpDesk.aspx.cs" Inherits="HelpDesk" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-primary" style="margin-left: 12px">

        <div class="panel-heading">
            <h3 class="panel-title">Help Desk</h3>
        </div>
        <div class="panel-body">
            <div class="row _masterForm">
                <table width="100%">
                    <tr>
                        <td width="50%">
                            <div class="input-group form-group" style="margin-left:0px">
                                <asp:Label runat="server" ID="lblDelerCode" Text="Dealer Code" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtDealerCode" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                            <div class="input-group form-group"  style="margin-left:0px">
                                <asp:Label runat="server" ID="lblUsername" Text="Username" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtUsername" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                            <div class="input-group form-group"  style="margin-left:0px">
                                <asp:Label runat="server" ID="lblModule" Text="Select Module" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlModule" runat="server" AppendDataBoundItems="True" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck"
                                    DataSourceID="edsddlModuleHP" DataTextField="MenuName" DataValueField="MenuID">
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlModuleHP" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.ParentMenuID IS NULL and it.Active = true" DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OMNUs">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group"  style="margin-left:0px">
                                <asp:Label runat="server" ID="lbltextarea" Text="Query" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtQuery" TextMode="MultiLine" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                            <asp:Button runat="server" ID="btnSubmit" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />

                        </td>
                        <td>
                            <h3 style="text-align: center">
                                <strong>VC ERP CONSULTING (P) LTD.</strong>
                                <br />
                                605, Iscon Elegance,<br />
                                Opp. Karnavati Club, S.G. Road,<br />
                                Ahmedabad-380015. Gujarat, INDIA<br />
                                Tel.: +91-79-66168911/8788<br />
                            </h3>
                            <a href="http://www.vc-erp.com/" target="_blank">
                                <img src="Images/VC.png" style="width: 40%; margin-left: 23%;" /></a></td>
                    </tr>
                </table>


            </div>
        </div>
    </div>
</asp:Content>

