<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MessageInbox.aspx.cs" Inherits="Marketing_MessageInbox" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
   <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <asp:GridView ID="gvMessageInbox" runat="server" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" CssClass="table" DataKeyNames="MessageID" DataSourceID="edsgvMessageInbox" AllowSorting="true" AllowPaging="true" PageSize="10" EmptyDataText="No Message Found" OnRowCommand="gvMessageInbox_RowCommand">
                        <Columns>
                            <asp:TemplateField HeaderText="Group ID" Visible="false">
                                <ItemTemplate>
                                    <asp:Label ID="lblMessageID" runat="server" Text='<%# Bind("OMSG.MessageID") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="OMSG.Subject" HeaderText="Subject" SortExpression="OMSG.Subject" />
                            <asp:BoundField DataField="OMSG.MessageDate" HeaderText="Date" SortExpression="OMSG.MessageDate" DataFormatString='{0:dd/MM/yyyy}' />
                            <asp:BoundField DataField="OMSG.MessageTime" HeaderText="Time" SortExpression="OMSG.MessageTime" />
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnDetails" ToolTip="View" CommandName="ShowMsg" CommandArgument='<%# String.Format("{0},{1}",Eval("MSG1ID"),Eval("ParentID")) %>' runat="server" CssClass="btn btn-default"><img src="../Images/read.png" alt="Edit" style="width:20px"></img></asp:LinkButton>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                                    <asp:LinkButton ID="btnDelete" ToolTip="Delete" CommandName="DeleteMsg" OnClientClick="return confirm('Are you sure want to delete this message?');" CommandArgument='<%# Bind("OMSG.MessageID") %>' CssClass="btn btn-default" runat="server"><img src="../Images/delete2.png" alt="Delete" style="width:20px"></img></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:EntityDataSource ID="edsgvMessageInbox" runat="server" ConnectionString="name=DDMSEntities" DefaultContainerName="DDMSEntities" EnableFlattening="False" Where="it.OMSG.Active = true and ((it.ParentID == @ParentID and it.ID = @UserID) or it.ID = @ParentID) and it.OMSG.MessageDate <= @DateNow" EntitySetName="MSG1" Include="OMSG">
                        <WhereParameters>
                            <asp:Parameter Name="DateNow" Type="DateTime" DefaultValue='2014/01/01' />
                            <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                            <asp:SessionParameter Name="UserID" SessionField="UserID" DbType="Int32" />
                        </WhereParameters>
                    </asp:EntityDataSource>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSubject" runat="server" Text="Subject" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSubject" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblMessageBody" runat="server" Text="Message Body" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtMessageBody" runat="server" Height="300px" TextMode="MultiLine" Enabled="false" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>

            </div>

        </div>
    </div>
</asp:Content>

