import SwiftUI

struct JobItemView: View {
    let user: AppUser

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)

            Text(user.username)
                .font(.subheadline)
                .lineLimit(1)

            Text("Booking Date: \(user.bookingDate)")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Pickup: \(user.origin)")
                .font(.caption2)

            Text("Destination: \(user.destination)")
                .font(.caption2)

            Button("Accept") {
                print("Accepted job from: \(user.username)")
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    JobItemView(user: AppUser(
        id: "1",
        name: "Arun",
        username: "arun_09",
        contact: "9876543210",
        bookingDate: "2025-06-13",
        origin: "Chennai",
        destination: "Madurai"
    ))
}
