//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import MessageUI

class CustomMailComposerViewController: MFMailComposeViewController {

    init(recipients: [String]?, subject: String = "", body: String = "", messageBodyIsHTML: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        setToRecipients(recipients)
        setSubject(subject)
        setMessageBody(body, isHTML: messageBodyIsHTML)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
