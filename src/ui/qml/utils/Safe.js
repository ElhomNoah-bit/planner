// Safe.js - QML Safety Helpers
// Provides safe wrappers for handling undefined/null values in QML bindings

/**
 * Safe string conversion with default value
 * @param {*} v - Value to convert to string
 * @param {string} d - Default value if v is undefined/null (default: "")
 * @returns {string} The string value or default
 */
export function s(v, d) {
    if (d === undefined) {
        d = "";
    }
    if (v === undefined || v === null) {
        return d;
    }
    return String(v);
}

/**
 * Safe number conversion with default value
 * @param {*} v - Value to convert to number
 * @param {number} d - Default value if v is undefined/null/NaN (default: 0)
 * @returns {number} The numeric value or default
 */
export function n(v, d) {
    if (d === undefined) {
        d = 0;
    }
    if (v === undefined || v === null) {
        return d;
    }
    var num = Number(v);
    return isNaN(num) ? d : num;
}

/**
 * Safe boolean conversion with default value
 * @param {*} v - Value to convert to boolean
 * @param {boolean} d - Default value if v is undefined/null (default: false)
 * @returns {boolean} The boolean value or default
 */
export function b(v, d) {
    if (d === undefined) {
        d = false;
    }
    if (v === undefined || v === null) {
        return d;
    }
    return Boolean(v);
}

/**
 * Safe object property access
 * @param {object} obj - Object to access
 * @param {string} prop - Property name
 * @param {*} d - Default value if property doesn't exist
 * @returns {*} The property value or default
 */
export function prop(obj, prop, d) {
    if (d === undefined) {
        d = null;
    }
    if (obj === undefined || obj === null || !obj.hasOwnProperty(prop)) {
        return d;
    }
    return obj[prop];
}
