<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmpHierarchyTree.aspx.cs" Inherits="Reports_EmpHierarchyTree" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/treeView/jquery.treeView.css" rel="stylesheet" />
    <script src="../Scripts/treeView/jquery.treeView.js"></script>
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function Relaod() {
            $('.divtreeview ul:first').treeView();

            if ($(".divtreeview li").length > 0) {

                $(".divtreeview li[dataid=open]").each(function (index) {
                    $(this).click();
                });
                var hdnUserID = $(".hdnSUserID").val();
                $(".divtreeview li[empid=" + hdnUserID + "]").addClass('ownli');
            }
        }

        function expandAll() {
            $('.treeview').treeView('expandAll');
            return false;
        }

        function collapseAll() {
            $('.treeview').treeView('collapseAll');
            return false;
        }
    </script>
    <style>
        .ownli {
            font-weight: 900;
            color: blue;
        }

            .ownli ul {
                font-weight: normal;
                color: black;
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="1"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" CssClass="btn btn-default" OnClick="btnGenerat_Click" TabIndex="8" />&nbsp;&nbsp;&nbsp;&nbsp;
                         <asp:LinkButton ID="Button1" runat="server" Text="EXPAND ALL" OnClientClick="return expandAll();" TabIndex="8" />&nbsp;&nbsp;&nbsp;&nbsp;
                        <asp:LinkButton ID="Button2" runat="server" Text="COLLAPSE ALL" OnClientClick="return collapseAll();" TabIndex="8" />
                    </div>
                </div>
                <div class="col-lg-12" style="overflow-y: scroll; height: 500px; border: 3px solid;">
                    <input type="hidden" id="hdnSUserID" runat="server" class="hdnSUserID" value="0" />
                    <div class="divtreeview">
                        <asp:Repeater runat="server" ID="treeview" OnItemDataBound="treeview_ItemDataBound1">
                            <HeaderTemplate>
                                <ul>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <li id="liMenuItem" runat="server" empid='<%# Eval("EMPID") %>' dataid='<%# Eval("Attr") %>'>
                                    <%# Eval("TEXT") %>
                                    <asp:PlaceHolder ID="PlaceHolder1" runat="server"></asp:PlaceHolder>
                                </li>
                            </ItemTemplate>
                            <FooterTemplate>
                                </ul>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

