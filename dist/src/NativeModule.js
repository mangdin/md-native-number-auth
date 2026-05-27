import { NativeModules } from 'react-native';
const { MdNumberAuth } = NativeModules;
if (!MdNumberAuth) {
    // eslint-disable-next-line no-console
    console.warn('[md-native-number-auth] Native module "MdNumberAuth" not found. ' +
        'Did you forget to rebuild the app after installing the package?');
}
export default MdNumberAuth;
