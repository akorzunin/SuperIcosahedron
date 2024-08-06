(function functionToExecute() {
  // Open the database connection.
  var open = indexedDB.open("/userfs");

  open.onupgradeneeded = function () {
    // Define the database schema if necessary.
    var db = open.result;
    var store = db.createObjectStore("/userfs");
    console.log("------------> Upgraded userfs?");
  };

  open.onsuccess = function () {
    var db = open.result;
    var key = "/userfs/godot/app_userdata/SuperIcosahedron/settings.cfg";

    // Write file to DB
    // var tx = db.transaction('files', 'readwrite');
    // var store = tx.objectStore('files');
    // store.put(null, "test");

    // Later, read file back out of DB
    var tx2 = db.transaction("FILE_DATA");
    var store2 = tx2.objectStore("FILE_DATA");
    var request = store2.get(key);

    request.onsuccess = function (e) {
      // Got the file!
      var file = request.result;

      if (file == null) {
        alert("You haven't generated any results yet.");
        console.log("File is null");
        return;
      } else {
        console.log("Is int8array: " + (file.contents instanceof Int8Array));
      }

      var blob = new Blob([file.contents], { type: "text/csv;charset=utf-8;" });
      var link = document.createElement("a");
      link.href = window.URL.createObjectURL(blob);
      link.download = "webSettings.cfg";
      link.click();
    };
  };
})();
