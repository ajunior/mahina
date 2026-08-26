pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Structured address form: street, city, state/province, postal code, country.
//
// Usage:
//   AddressInput {
//       onAddressChanged: (a) => model.address = a
//   }
//   AddressInput { address: { street: "123 Main St", city: "Springfield", state: "IL", zip: "62701", country: "US" } }
Item {
    id: root

    property var address: ({ street: "", city: "", state: "", zip: "", country: "" })

    signal addressEdited(var addr)

    implicitWidth:  360
    implicitHeight: _col.implicitHeight

    function _emit(): void {
        addressEdited({ street: _street.text, city: _city.text, state: _state.text, zip: _zip.text, country: _country.text })
    }

    Column {
        id:     _col
        width:  parent.width
        spacing: Theme.sp2

        // Street
        Input {
            id:          _street
            width:       parent.width
            placeholderText: "Street address"
            text:        root.address.street ?? ""
            onTextChanged: root._emit()
        }

        // City / State row
        Row {
            width: parent.width
            spacing: Theme.sp2
            Input {
                id:          _city
                width:       parent.width * 0.6 - Theme.sp1
                placeholderText: "City"
                text:        root.address.city ?? ""
                onTextChanged: root._emit()
            }
            Input {
                id:          _state
                width:       parent.width * 0.4 - Theme.sp1
                placeholderText: "State / Province"
                text:        root.address.state ?? ""
                onTextChanged: root._emit()
            }
        }

        // ZIP / Country row
        Row {
            width: parent.width
            spacing: Theme.sp2
            Input {
                id:          _zip
                width:       parent.width * 0.35 - Theme.sp1
                placeholderText: "ZIP / Postal"
                text:        root.address.zip ?? ""
                onTextChanged: root._emit()
            }
            Input {
                id:          _country
                width:       parent.width * 0.65 - Theme.sp1
                placeholderText: "Country"
                text:        root.address.country ?? ""
                onTextChanged: root._emit()
            }
        }
    }
}
