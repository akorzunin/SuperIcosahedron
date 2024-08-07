export const USER_CONFIG_KEY =
  "/userfs/godot/app_userdata/SuperIcosahedron/settings.cfg";

export async function getGodotFile(
  file: string = USER_CONFIG_KEY,
): Promise<Blob | null> {
  return new Promise((resolve, reject) => {
    const openRequest = indexedDB.open("/userfs");

    openRequest.onerror = function () {
      reject(new Error("Failed to open IndexedDB"));
    };

    openRequest.onupgradeneeded = function () {
      const db = openRequest.result;
      db.createObjectStore("FILE_DATA");
    };

    // https://stackoverflow.com/a/46385383/14349118
    openRequest.onsuccess = async function () {
      const db = openRequest.result;
      const tx = db.transaction("FILE_DATA", "readonly");
      const store = tx.objectStore("FILE_DATA");
      const getRequest = store.get(file);

      getRequest.onerror = function () {
        console.error("Error reading file:", getRequest.error);
        reject(new Error("Failed to read file"));
      };

      getRequest.onsuccess = function () {
        const result = getRequest.result;
        if (!result) {
          resolve(null);
        } else {
          const blob = new Blob([result.contents], {
            type: "text/plain;charset=utf-8;",
          });
          resolve(blob);
        }
      };
    };
  });
}
