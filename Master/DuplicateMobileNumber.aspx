<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DuplicateMobileNumber.aspx.cs" Inherits="Reports_AssetList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function ChangeReportFor() {
            var ddlReportFor = $('.ddlReportFor').val();
            if (ddlReportFor == 3) {
                $('.divMobileWidth').attr('style', 'display:block;');
            }
            else {
                $(".txtMobileWidth").val('');
                $('.divMobileWidth').attr('style', 'display:none;');
            }
        }
        $(function () {
            ChangeReportFor();
        })
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="col-lg-4">
                <div class="input-group form-group">
                    <asp:Label Text="Report For" runat="server" CssClass="input-group-addon" />
                    <asp:DropDownList ID="ddlReportFor" TabIndex="1" runat="server" CssClass="ddlReportFor form-control" onchange="ChangeReportFor();">
                        <asp:ListItem Text="Duplicate Number" Value="1" Selected="True" />
                        <asp:ListItem Text="Blank Mobile Number " Value="2" />
                        <asp:ListItem Text="Mobile Number Width" Value="3" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="col-lg-4 divMobileWidth" id="divMobileWidth" runat="server">
                <div class="input-group form-group">
                    <asp:Label ID="mobileWidth" runat="server" Text="Mobile Width" CssClass="input-group-addon"></asp:Label>
                    <asp:TextBox ID="txtMobileWidth" runat="server" CssClass="form-control txtMobileWidth" Style="background-color: rgb(250, 255, 189);" TabIndex="2" MaxLength="2"></asp:TextBox>
                </div>
            </div>
            <div class="col-lg-4">
                 <div class="input-group form-group">
                    <asp:Button Width="291" TabIndex="18" Text="Export-Detail-Data" ID="btnDetailData" OnClick="btnDetailData_Click" CssClass="btnDetailData btn btn-default" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

