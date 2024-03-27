<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DealerExclude.aspx.cs" Inherits="Sales_DealerExclude" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .tdschemeNo {
            width: 10px !important;
        }
    </style>
    <script type="text/javascript">
        function downloadMapping() {
            window.open("../Document/CSV Formats/DealertemIncExclude.csv");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label Text="Line Item Start Stop" runat="server" ID="Label4" CssClass="input-group-addon" Style="min-width: 175px !important;" />
                        <asp:DropDownList ID="ddlExclude" runat="server" TabIndex="7" CssClass="ddlIsPair form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlExclude_SelectedIndexChanged"> 
                            <asp:ListItem Value="-1" Text="Select"></asp:ListItem>
                            <asp:ListItem Value="false" Text="Stop"></asp:ListItem>
                            <asp:ListItem Value="true" Text="Start"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

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
            <div class="col-lg-12">
                <asp:GridView ID="gvProductMappingMissData" Width="100%" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField DataField="SchemeNo" HeaderText="Scheme No" ItemStyle-Width="5%" HeaderStyle-Width="7%" />
                        <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" ItemStyle-Width="10%" HeaderStyle-Width="7%"  />
                        <asp:BoundField DataField="AssetCode" HeaderText="Assest Code" ItemStyle-Width="10%" HeaderStyle-Width="7%"  />
                        <asp:BoundField DataField="ErrorMsg" HeaderText="Error Message" ItemStyle-Width="70%" HeaderStyle-Width="70%"  />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

