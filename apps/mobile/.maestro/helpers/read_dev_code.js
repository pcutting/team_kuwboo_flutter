// Reads the 6-digit dev OTP code out of the on-screen banner and stores
// it in maestroOutput.devCode. The banner widget has the stable id
// "auth.otp.banner_dev_code" — its rendered text contains the code as
// the only sequence of 6 contiguous digits ("TEST BUILD — your code is
// 123456"). This script is invoked from flows/02_send_and_otp.yaml.

var bannerText = maestro.copyTextFrom({ id: 'auth.otp.banner_dev_code' });
var match = (bannerText || '').match(/(\d{6})/);
if (!match) {
  throw new Error(
    'read_dev_code.js: could not find a 6-digit code in banner text: ' +
      JSON.stringify(bannerText)
  );
}
output.devCode = match[1];
