// This function creates a standard table with column/rows
// Parameter Information
// objArray = Anytype of object array, like JSON results
// enableHeader (optional) = Controls if you want to hide/show, default is show
//function CreateTableView(objArray, enableHeader) {
function CreateTableView(objArray, enableHeader) {

    //if (enableHeader === undefined) {
    //    enableHeader = true; //default enable headers
    //}

    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
    
    var str = '<table>';

    // table head
    //if (enableHeader) {
        str += '<thead><tr>';
        for (var index in array[0]) {
            str += '<th scope="col">' + index + '</th>';
        }
        str += '</tr></thead>';
    //}

    // table body
    str += '<tbody>';
    for (var i = 0; i < array.length; i++) {
        str += (i % 2 == 0) ? '<tr class="alt">' : '<tr>';
        for (var index in array[i]) {
            str += '<td>' + array[i][index] + '</td>';
        }
        str += '</tr>';
    }
    str += '</tbody>'
    str += '</table>';
    return str;
}

// This function creates a details view table with column 1 as the header and column 2 as the details
// Parameter Information
// objArray = Anytype of object array, like JSON results
// enableHeader (optional) = Controls if you want to hide/show, default is show
//function CreateListView(objArray, enableHeader) {
function CreateListView(objArray) {

    //if (enableHeader === undefined) {
    //    enableHeader = true; //default enable headers
    //}

    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;

    var str = '<table>';
    str += '<tbody>';

    for (var i = 0; i < array.length; i++) {
        var row = 0;
        for (var index in array[i]) {
            str += (row % 2 == 0) ? '<tr class="alt">' : '<tr>';

            //if (enableHeader) {
                str += '<td scope="row">' + index + '</td>';
            //}

            str += '<td>' + array[i][index] + '</td>';
            str += '</tr>';
            row++;
        }
    }
    str += '</tbody>'
    str += '</table>';
    return str;
}
