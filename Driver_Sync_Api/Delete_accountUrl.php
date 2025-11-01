<?php
session_start();
header("Content-Type: text/html");

// Include the database connection
include 'db.php';

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    die("Error: You must be logged in to delete your account.");
}

// Get user ID from session
$user_id = $_SESSION['user_id'];

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Delete user from database
    $sql = "DELETE FROM users WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);

    if ($stmt->execute()) {
        session_destroy(); // End user session
        echo "<p>Your account has been deleted successfully.</p>";
    } else {
        echo "<p>Error deleting account. Please try again later.</p>";
    }

    $stmt->close();
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Account - Driver Sync</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; padding: 20px; background-color: #f8f8f8; }
        h1 { color: #d9534f; }
        p { color: #555; line-height: 1.6; }
        form { margin-top: 20px; }
        button { background-color: #d9534f; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        button:hover { background-color: #c9302c; }
    </style>
</head>
<body>
    <h1>Delete Account</h1>
    <p>Warning: Deleting your account is permanent and cannot be undone.</p>
    <form method="POST">
        <button type="submit">Delete My Account</button>
    </form>
</body>
</html>