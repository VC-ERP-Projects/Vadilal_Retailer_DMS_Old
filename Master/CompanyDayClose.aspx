<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CompanyDayClose.aspx.cs" Inherits="Master_CompanyDayClose" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-12">
                    <div class="col-lg-6">
                        <div class="panel panel-body panel-default">
                            <div class="panel-heading panel-title">
                                <h4>Open Day Close (DMS)</h4>
                            </div>
                            <div class="panel-body">
                                <div class="input-group form-group" id="divDistributor" runat="server">
                                    <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCustCode" runat="server" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetCustomerByTypePlantState" ContextKey="0-0-0-2,4" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                                    </asp:AutoCompleteExtender>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblIsConfirm" runat="server" Text="Is Confirm" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkIsConfirm" TabIndex="4" Checked="false" runat="server" CssClass="chkIsConfirm form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Button ID="btnGenerat" runat="server" Text="Go" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                                    &nbsp;
                                    <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSubmit_Click" />
                                </div>
                                <div class="row">
                                    <div class="col-lg-12">
                                        <asp:Label ForeColor="Red" Font-Bold="true" ID="lblMsg" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="panel panel-body panel-default">
                            <div class="panel-heading panel-title">
                                <h4>Day End Revert (Pulse)</h4>
                            </div>
                            <div class="panel-body">
                                <div class="input-group form-group" id="div1" runat="server">
                                    <asp:Label ID="lblEmp" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtEmp" runat="server" MaxLength="200" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtManagerCode" runat="server" ServicePath="../WebService.asmx"
                                        UseContextKey="true" ServiceMethod="GetEmployee" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmp">
                                    </asp:AutoCompleteExtender>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Button ID="btnDayEndGo" runat="server" Text="Go" CssClass="btn btn-default" OnClick="btnDayEndGo_Click" />
                                    &nbsp;
                                    <asp:Button ID="btnDayEndSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnDayEndSubmit_Click" />
                                </div>
                                <div class="row">
                                    <div class="col-lg-12">
                                        <asp:Label ForeColor="Red" Font-Bold="true" ID="lblDayEnd" runat="server" />
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

