<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TempCustomerCompeititor.aspx.cs" Inherits="Master_TempCustomerCompeititor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript">

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
        }
        
        function Reload() {
            $('.gallery').on('click', function () {
                $('.imagepreview').attr('src', $(this).attr('href'));
                $('#imagemodal').modal('show');
                return false;
            });
            //$('a.gallery').colorbox();
            $('.txtBrand')
              // don't navigate away from the field on tab when selecting an item
              //.on("keydown", function (event) {
              //    if (event.keyCode === $.ui.keyCode.TAB &&
              //        $(this).autocomplete("instance").menu.active) {
              //        event.preventDefault();
              //    }

              //})
              .autocomplete({
                  source: function (request, response) {
                      $.ajax({
                          type: "POST",
                          url: "../Service.asmx/GetBrandlist",
                          dataType: "json",
                          data: "{ 'prefixText': '" + request.term + "', 'count': '0', 'contextKey': '' }",
                          contentType: "application/json; charset=utf-8",
                          success: function (data) {
                              response($.map(data.d, function (item) {
                                  return {
                                      label: item.Text,
                                      value: item.Text,
                                      id: item.Value
                                  };
                              }))
                          },
                          error: function (XMLHttpRequest, textStatus, errorThrown) {
                          }
                      });
                  },
                  search: function () {
                      // custom minLength
                      var term = extractLast(this.value);
                      if (term.length < 0) {
                          return false;
                      }
                  },
                  focus: function () {
                      // prevent value inserted on focus
                      return false;
                  },
                  select: function (event, ui) {
                      var terms = split(this.value);
                      // remove the current input
                      terms.pop();
                      // add the selected item
                      terms.push(ui.item.value);

                      terms.push("");
                      this.value = terms.join(",");
                      return false;
                  },
                  error: function (XMLHttpRequest, textStatus, errorThrown) {
                      ModelMsg("Please select Proper Brand", 3);
                      return false;
                  }
              });

        }

        function _btnCheck() {
            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
        function EmployeeValidation() {
            if ($('.txtEmpName').val().split('-').length != 3 && $('.txtEmpName').val() != "") {
                ModelMsg("Please select proper employee.", 3);
            }
        }
        function autoCompleteComp_OnClientPopulating(sender, args) {
            var SelEmpID = $('.txtEmpName').is(":visible") ? $('.txtEmpName').val().split('-').pop() : "0";

            sender.set_contextKey(SelEmpID + "-" + $(".ddlOption").val());
        }

        function acettxtCity_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpName').is(":visible") ? $('.txtEmpName').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpName').is(":visible") ? $('.txtEmpName').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }

        function acettxtBrand_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpName').is(":visible") ? $('.txtEmpName').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-" + EmpID);
        }

        function split(val) {
            return val.split(/,\s*/);
        }
        function extractLast(term) {
            return split(term).pop();
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            //var EmpID = $('.txtEmpName').is(":visible") ? $('.txtEmpName').val().split('-').pop() : "0";
            //var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0-0");
        }
        function autoCompleteRouteCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpName').is(":visible") ? $('.txtEmpName').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }
        function ClearOtherConfig() {
            if ($(".txtEmpName").length > 0) {
                $(".txtCode").val('');
                $(".txtOName").val('');
                $(".txtContactPerson").val('');
                $(".txtEmailID").val('');
                $(".txtMobileNo").val('');
                $(".txtAddress1").val('');
                $(".txtAddress2").val('');
                $(".txtContactPerson").val('');
                $(".txtLocation").val('');
                $(".txtpincode").val('');
                $(".txtRegion").val('');
                $(".txtCity").val('');
                $(".txtBrand").val('');
                $(".txtdistributor").val('');
                $(".txtBeatCodeName").val('');
                $(".txtCreatedOn").val('');
                $(".txtcreatedby").val('');
                $(".txtlatitude").val('');
                $(".txtlongitude").val('');
                $(".txtIstemp").val('');
                $(".txtTempcode").val('');
                $(".txtactive").val('');
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlOption" runat="server" CssClass="ddlOption form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlOption_SelectedIndexChanged" TabIndex="1">
                            <asp:ListItem Text="Competitor" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Temporary" Value="2"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmp" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmpName" runat="server" CssClass="txtEmpName form-control" Style="background-color: rgb(250, 255, 189);" Onchange="ClearOtherConfig()" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtEmpName" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmpName">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblcode" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="txtCode form-control" onfocus="EmployeeValidation()" OnTextChanged="txtCode_TextChanged" AutoPostBack="true" Style="background-color: rgb(250, 255, 189);" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetCompcreateEmpTeam" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteComp_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6">
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btnSave btn btn-default" TabIndex="4" OnClientClick="return _btnCheck();" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" TabIndex="5" UseSubmitBehavior="false" CausesValidation="false"
                        OnClick="btnCancel_Click" />
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lbloutletName" runat="server" Text="Outlet Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtOName" runat="server" CssClass="txtOName form-control" MaxLength="50" autocomplete="off" TabIndex="6" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblContactPerson" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtContactPerson" MaxLength="50" CssClass="txtContactPerson form-control" runat="server" TabIndex="7"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmailID" runat="server" Text="Email ID" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmailID" TabIndex="8" runat="server" MaxLength="50" CssClass="txtEmailID form-control" data-bv-emailaddress="true"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblMobileNo" runat="server" Text="MobileNo" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtMobileNo" runat="server" CssClass="txtMobileNo form-control" TabIndex="9" onkeypress="return isNumberKey(event);" MaxLength="10" onpaste="return false;"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblAddress1" runat="server" Text="Address-1" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAddress1" TabIndex="10" MaxLength="150" runat="server" CssClass="txtAddress1 form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6" id="divaddress2" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="lbladdress2" runat="server" Text="Address-2" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAddress2" TabIndex="11" MaxLength="150" runat="server" CssClass="txtAddress2 form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lbllocation" runat="server" Text="Location" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtLocation" TabIndex="12" runat="server" MaxLength="100" CssClass="txtLocation form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblpincode" runat="server" Text="Pincode" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtpincode" TabIndex="13" MaxLength="20" runat="server" CssClass="txtpincode form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblstate" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" TabIndex="14" runat="server" CssClass="txtRegion form-control" Style="background-color: rgb(250, 255, 189);" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblcity" runat="server" Text="City" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCity" TabIndex="15" runat="server" CssClass="txtCity form-control" Style="background-color: rgb(250, 255, 189);" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCity" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetCitysCurrHierarchy" OnClientPopulating="acettxtCity_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6" id="divbrand" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="lblbrand" runat="server" Text="Brand" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBrand" TabIndex="16" runat="server" MaxLength="50" CssClass="txtBrand form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldistributor" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtdistributor" TabIndex="17" runat="server" CssClass="txtdistributor form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtDist" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetDistCurrHierarchy" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdistributor">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblbeatcodename" runat="server" Text="Beat Code & Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBeatCodeName" TabIndex="18" runat="server" CssClass="txtBeatCodeName form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtroute" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetCompetitorRouteByEmpID" OnClientPopulating="autoCompleteRouteCode_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtBeatCodeName">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedOn" runat="server" Text="Created On" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedOn" runat="server" Enabled="false" CssClass="txtCreatedOn form-control" TabIndex="19" MaxLength="8"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblcreatedby" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtcreatedby" TabIndex="20" runat="server" Enabled="false" MaxLength="50" CssClass="txtcreatedby form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lbllatitude" runat="server" Text="Latitude" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtlatitude" runat="server" CssClass="txtlatitude form-control" Enabled="false" TabIndex="21"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lbllongitude" runat="server" Text="Longitude" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtlongitude" runat="server" CssClass="txtlongitude form-control" Enabled="false" TabIndex="22"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsTemp" runat="server" Text="Is Temp Customer?" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtIstemp" runat="server" CssClass="txtIstemp form-control" Enabled="false" TabIndex="23"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6" id="divtempcode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbltempCode" runat="server" Text="Temporary Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtTempcode" runat="server" CssClass="txtTempcode form-control" Enabled="false" TabIndex="24"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6" id="divactive" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="lblactive" runat="server" Text="Active Status" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtactive" runat="server" CssClass="txtactive form-control" Enabled="false" TabIndex="25"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-1">
                    <div class="input-group form-group">
                        <a class="gallery" id="img1" runat="server">Image 1</a>
                    </div>
                </div>
                <div class="col-lg-1">
                    <div class="input-group form-group">
                        <a class="gallery" id="img2" runat="server">Image 2</a>
                    </div>
                </div>
                <div class="col-lg-1">
                    <div class="input-group form-group">
                        <a class="gallery" id="img3" runat="server">Image 3</a>
                    </div>
                </div>
                <div class="col-lg-1">
                    <div class="input-group form-group">
                        <a class="gallery" id="img4" runat="server">Image 4</a>
                    </div>
                </div>
                <!-- Creates the bootstrap modal where the image will appear -->
                <div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                <h4 class="modal-title" id="myModalLabel">Image preview</h4>
                            </div>
                            <div class="modal-body">
                                <img src="" id="imagepreview" class="imagepreview">
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>


