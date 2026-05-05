import Contacts
import SwiftData
import Foundation

@MainActor
final class ContactImportService {
    private let store = CNContactStore()

    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }

    func importContacts(modelContext: ModelContext) async -> [Client] {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keys)
        var imported: [Client] = []

        do {
            try store.enumerateContacts(with: request) { cnContact, _ in
                guard !cnContact.givenName.isEmpty else { return }

                let email = cnContact.emailAddresses.first?.value as String? ?? ""
                let phone = cnContact.phoneNumbers.first?.value.stringValue ?? ""

                let client = Client(
                    firstName: cnContact.givenName,
                    lastName: cnContact.familyName,
                    company: cnContact.organizationName,
                    email: email,
                    phone: phone
                )
                imported.append(client)
            }

            for client in imported {
                modelContext.insert(client)
            }
            try? modelContext.save()
        } catch {}

        return imported
    }
}
