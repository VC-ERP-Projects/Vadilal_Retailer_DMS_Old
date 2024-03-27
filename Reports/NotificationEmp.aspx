<%@ Page Language="C#" AutoEventWireup="true" CodeFile="NotificationEmp.aspx.cs" Inherits="Reports_NotificationEmp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <link href="../Scripts/BootStrapCSS/bootstrap-theme.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />
    <link href="../css/base.css" rel="stylesheet" type="text/css" />
    <link href="../css/index.css" rel="stylesheet" type="text/css" />

    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/jquery.blockUI.js" type="text/javascript"></script>
    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>

    <script type="text/javascript">
        $(function () {
            Load();
        });

        function unblockUI() {
            $.unblockUI();
        }

        function blockUI() {
            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });
        }

        function ReadAllNoti() {
            blockUI();
            $.ajax({
                type: "POST",
                url: "NotificationEmp.aspx/ReadAllReminder",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        Load();
                    }
                    unblockUI();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest);
                    unblockUI();
                }
            });
        }

        function DeleteAllNoti() {
            blockUI();
            $.ajax({
                type: "POST",
                url: "NotificationEmp.aspx/DeleteAllReminder",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        Load();
                    }
                    unblockUI();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest);
                    unblockUI();
                }
            });
        }

        function DeleteNoti(Id) {
            blockUI();
            $.ajax({
                type: "POST",
                url: "NotificationEmp.aspx/DeleteReminder",
                data: '{GCM1ID: ' + Id + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        Load();
                    }
                    unblockUI();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest);
                    unblockUI();
                }
            });
        }

        function ReadNoti(Id) {
            blockUI();
            $.ajax({
                type: "POST",
                url: "NotificationEmp.aspx/ReadReminder",
                data: '{GCM1ID: ' + Id + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        Load();
                    }
                    unblockUI();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest);
                    unblockUI();
                }
            });
        }

        function Load() {

            $.ajax({
                url: 'NotificationEmp.aspx/GetTableData',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                data: "{}",
                dataType: "json",
                success: function (data) {
                    var json = $.parseJSON(data.d);

                    $('#gvdata').DataTable({
                        data: json,
                        bFilter: true,
                        "ordering": false,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '60vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "aoColumnDefs": [
                            { "width": "60px", "targets": 0 },
                            { "width": "80px", "targets": 1 },
                            { "width": "250px", "targets": 2 },
                            { "width": "80px", "targets": 3 },
                            {
                                "width": "10px", "targets": 4,
                                "mRender": function (data, type, full) {
                                    if (data.split('-')[0] == "UnRead") {
                                        return '<a onclick="ReadNoti(' + data.split('-')[1] + ');" href="#">Read</a> &nbsp;&nbsp;<a onclick="DeleteNoti(' + data.split('-')[1] + ');" href="#">Delete</a>';
                                    }
                                    else
                                        return '&nbsp;&nbsp;<a onclick="DeleteNoti(' + data.split('-')[1] + ');" href="#">Delete</a>';
                                }
                            }
                        ],
                        columns: [
                              { title: "Date", data: "Date" },
                              { title: "Title", data: "Title" },
                              { title: "Body", data: "Body" },
                              { title: "Employee", data: "Employee" },
                              { title: "Status", data: "Status" }
                        ]
                    });
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest);
                }
            });
        }

    </script>
    <style type="text/css">
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyRight {
            text-align: right;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="panel">
            <div class="panel-body">
                <h4>Notification List</h4>

                <a href="#" onclick="DeleteAllNoti();" style="float: right;">Delete All</a>
                <a href="#" onclick="ReadAllNoti();" style="float: right; padding-right: 15px;">Read All</a>
                <br />
                <table id="gvdata" class="table table-bordered" style="width: 100%; font-size: 11px;"></table>
            </div>
        </div>

    </form>
</body>
</html>

