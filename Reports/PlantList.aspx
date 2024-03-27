<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PlantList.aspx.cs" Inherits="Reports_PlantList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style type="text/css">
        .ifmData {
            height: 500px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="5" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStates" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="14" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="15" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
        </div>
        <iframe id="ifmData" style="width: 100%;" class="ifmData embed-responsive-item" runat="server" onload="ifmData_Load"></iframe>
    </div>
</asp:Content>

