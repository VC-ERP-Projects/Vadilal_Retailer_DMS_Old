<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="LeaveApproval.aspx.cs" Inherits="Master_LeaveApproval" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var availableEmployee = [];

        var UserID = '<% =UserID%>';
        $(document).ready(function () {

            $('.txtSearch').on('keyup', function () {
                var word = this.value;
                $('.gvApprovalList > tbody tr').each(function () {
                    var emp = $("span[id='lblEmp']", this).text();
                    if (($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0) || (emp.toUpperCase().indexOf(word.toUpperCase()) >= 0))
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });

            var today = '<%=DateTime.Now.ToShortDateString()%>';
            $('#txtToDate').val(today);
            $('#txtFromDate').val(today);

            FillData();
        });

        function FillData() {
            $.ajax({
                url: 'LeaveApproval.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {

                    if (result.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {

                        var Employee = result.d[0];
                        availableEmployee = [];
                        for (var i = 0; i < Employee.length; i++) {
                            availableEmployee.push(Employee[i]);
                        }
                        $(".AutoEmp").autocomplete({
                            source: availableEmployee,
                            minLength: 0,
                            scroll: true
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }

        function CheckMain(chk) {

            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck').find('input:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked'))
                    $('.chkCheck').find('input:enabled').prop('checked', true);
                else
                    $('.chkCheck').find('input:enabled').prop('checked', false);

            }
        }

    </script>
    <style>
        #divApprovalList .gvApprovalList.table > tbody > tr > td {
            padding-bottom: 3px;
            padding-top: 3px;
            vertical-align: middle;
        }


        .ui-menu-item {
            font-size: 12px !Important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Leave From Date" CssClass="input-group-addon"></asp:Label>
                        <input runat="server" type="text" id="txtFromDate" name="txtFromDate" class="fromdate form-control" onkeyup="return ValidateDate(this);" tabindex="1" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Leave To Date" CssClass="input-group-addon"></asp:Label>
                        <input runat="server" type="text" id="txtToDate" name="txtToDate" class="todate form-control" onkeyup="return ValidateDate(this);" tabindex="1" />
                    </div>
                </div>
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="AutoEmp" runat="server" CssClass="AutoEmp form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Request For" class="input-group-addon" />
                        <asp:DropDownList ID="ddlRequestType" class="ddlRequestType" runat="server" CssClass="ddlRequestType form-control">
                            <asp:ListItem Text="---Select---" Value="0" Selected="True" />
                            <asp:ListItem Text="Open" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Approved" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Reject" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-info" OnClick="btnSearch_Click" />
                        &nbsp;
                        <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-success" OnClick="btnApprove_Click" />
                        &nbsp;
                        <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn btn-danger" OnClick="btnReject_Click" />
                    </div>
                </div>
            </div>

            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active" tabindex="9" style="outline: none;">
                    <div id="divApprovalList" class="tab-pane">
                        <asp:TextBox runat="server" placeholder="Search here" CssClass="txtSearch form-control" Style="float: right; max-width: 24.5%" />
                        <br />
                        <asp:GridView runat="server" ID="gvApprovalList" Font-Size="12px" CssClass="gvApprovalList table" HeaderStyle-CssClass="table-header-gradient"
                            AutoGenerateColumns="false" EmptyDataText="No Item Found." Width="100%" OnPreRender="gvApprovalList_PreRender">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr">
                                    <ItemTemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="1%" />
                                    <ItemStyle Font-Size="12px" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Check">
                                    <HeaderTemplate>
                                        <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblEmpID" CssClass="lblEmpID" runat="server" Style="display: none;" Text='<%#Eval("EmpID") %>'></asp:Label>
                                        <asp:Label ID="lblLeaveReqID" CssClass="lblLeaveReqID" runat="server" Style="display: none;" Text='<%#Eval("LeaveReqID") %>'></asp:Label>
                                        <asp:CheckBox CssClass="chkCheck" ID="chkCheck" runat="server" Enabled='<%# Eval("LeaveStatus").ToString() == "1" ? true : false %>'
                                            Checked='<%# Eval("LeaveStatus").ToString() == "1" ? false : true %>' onchange="CheckMain();" />
                                        <%--<input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="CheckMain();"/>--%>
                                    </ItemTemplate>
                                    <HeaderStyle Width="1%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Employee">
                                    <ItemTemplate>
                                        <asp:Label ID="lblEmp" CssClass="lblEmp" runat="server" Text='<%#Eval("Emp") %>'></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle Width="8%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Leave Period">
                                    <ItemTemplate>
                                        <%#Eval("Date") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="4%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="L.T.">
                                    <ItemTemplate>
                                        <%#Eval("LeaveCode") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="1.3%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Req. Days">
                                    <ItemTemplate>
                                        <%# Eval("NoOfDays") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="1.5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Half Day">
                                    <ItemTemplate>
                                        <%# Eval("HalfDay") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="6.5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Req. Date/Time">
                                    <ItemTemplate>
                                        <%#Eval("ReqDate") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="3.5%" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Days">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtAppDays" CssClass="txtAppDays allownumericwithdecimal form-control" Height="25px" Enabled='<%# Eval("LeaveStatus").ToString().Trim() == "1"  ? true: false %>' runat="server" BackColor="#ffffcc"></asp:TextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Width="2%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Remarks">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtRemarks" CssClass="txtRemarks form-control" Height="25px" Enabled='<%# Eval("LeaveStatus").ToString().Trim() == "1"  ? true: false %>' runat="server" BackColor="#ffffcc"></asp:TextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Width="5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Reason">
                                    <ItemTemplate>
                                        <%#Eval("Reason") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Balance">
                                    <ItemTemplate>
                                        <%# Eval("LeaveBalance") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="2.1%" />
                                </asp:TemplateField>

                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

