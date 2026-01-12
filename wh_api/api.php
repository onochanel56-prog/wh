<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json");

date_default_timezone_set("Asia/Vientiane");
$conn = new mysqli("localhost", "root", "", "wh_queue_db");
$conn->query("SET time_zone = '+07:00'");

$method = $_SERVER['REQUEST_METHOD'];

// ================= GET =================
if ($method === 'GET') {
    $action = $_GET['action'] ?? '';

    if ($action === 'get_slots') {
        $date = $_GET['date'];
        $zone = $_GET['zone'];
        $all_slots = ["09:00-11:00", "11:00-13:00", "13:00-15:00", "15:00-17:00", "17:00-19:00"];
        $response = [];
        foreach ($all_slots as $slot) {
            $limit_res = $conn->query("SELECT max_limit FROM slot_configs WHERE zone='$zone' AND time_slot='$slot' AND config_date='$date'");
            $max_limit = ($limit_res->num_rows > 0) ? $limit_res->fetch_assoc()['max_limit'] : 3;
            $booked = $conn->query("SELECT COUNT(*) as total FROM bookings WHERE zone='$zone' AND booking_date='$date' AND time_slot='$slot' AND booking_type='normal' AND status != 'rejected'")->fetch_assoc()['total'];
            $response[] = ["time" => $slot, "booked" => $booked, "limit" => $max_limit, "is_full" => $booked >= $max_limit];
        }
        echo json_encode($response); exit;
    }

    if ($action === 'get_tech_location') {
        $res = $conn->query("SELECT lat, lng, updated_at FROM tech_locations WHERE id=1");
        echo json_encode($res->fetch_assoc()); exit;
    }

    if ($action === 'get_forecast') {
        $data = [];
        for ($i = 0; $i < 7; $i++) {
            $d = date('Y-m-d', strtotime("+$i days"));
            $row = ['date' => $d, 'zones' => [], 'total' => 0];
            foreach (['A', 'B', 'C', 'D', 'E'] as $z) {
                $count = $conn->query("SELECT COUNT(*) as c FROM bookings WHERE booking_date='$d' AND zone='$z' AND status != 'rejected'")->fetch_assoc()['c'];
                $row['zones'][$z] = $count;
                $row['total'] += $count;
            }
            $data[] = $row;
        }
        echo json_encode($data); exit;
    }

    $result = $conn->query("SELECT * FROM bookings ORDER BY booking_date DESC, time_slot ASC");
    echo json_encode($result->fetch_all(MYSQLI_ASSOC));
}

// ================= POST =================
if ($method === 'POST') {
    
    // 1. LOGIN SYSTEM (ໃໝ່)
    if (isset($_POST['action']) && $_POST['action'] === 'login') {
        $username = $_POST['username'];
        $password = $_POST['password'];
        
        $sql = "SELECT * FROM users WHERE username='$username' AND password='$password'";
        $result = $conn->query($sql);
        
        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            echo json_encode(["status" => "success", "user" => $user]);
        } else {
            echo json_encode(["status" => "error", "message" => "Username ຫຼື Password ຜິດ!"]);
        }
        exit;
    }

    if (isset($_POST['action']) && $_POST['action'] === 'update_tech_location') {
        $lat = $_POST['lat']; $lng = $_POST['lng'];
        $conn->query("UPDATE tech_locations SET lat='$lat', lng='$lng' WHERE id=1");
        echo json_encode(["status" => "success"]); exit;
    }

    if (isset($_POST['action']) && $_POST['action'] === 'update_slot') {
        $date = $_POST['date']; $zone = $_POST['zone']; $slot = $_POST['time_slot']; $limit = $_POST['max_limit'];
        $check = $conn->query("SELECT * FROM slot_configs WHERE zone='$zone' AND time_slot='$slot' AND config_date='$date'");
        if ($check->num_rows > 0) $conn->query("UPDATE slot_configs SET max_limit=$limit WHERE zone='$zone' AND time_slot='$slot' AND config_date='$date'");
        else $conn->query("INSERT INTO slot_configs (zone, time_slot, config_date, max_limit) VALUES ('$zone', '$slot', '$date', $limit)");
        echo json_encode(["status" => "success"]); exit;
    }

    if (isset($_POST['action']) && ($_POST['action'] === 'accept_job' || $_POST['action'] === 'complete_job')) {
        $id = $_POST['id'];
        
        if ($_POST['action'] === 'accept_job') {
            $tech_name = $_POST['tech_name']; // ຊື່ຈາກ User Login
            $sql = "UPDATE bookings SET tech_status='accepted', tech_name='$tech_name', tech_start_time=NOW() WHERE id=$id";
        } else {
            $sql = "UPDATE bookings SET tech_status='completed', tech_end_time=NOW()";
            if (isset($_FILES['photo'])) {
                $target_dir = "uploads/";
                if (!is_dir($target_dir)) mkdir($target_dir, 0777, true);
                $filename = time() . "_" . basename($_FILES["photo"]["name"]);
                move_uploaded_file($_FILES["photo"]["tmp_name"], $target_dir . $filename);
                $sql .= ", photo_proof='$filename'";
            }
            $sql .= " WHERE id=$id";
        }
        $conn->query($sql);
        echo json_encode(["status" => "success"]); exit;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    if($input) {
        $sales_name = $input['sales_name']; // ຊື່ຈາກ User Login
        $name = $input['name']; $phone = $input['phone']; $product = $input['product'];
        $zone = $input['zone']; $date = $input['date']; $slot = $input['time_slot'];
        $type = $input['type']; $lat = $input['lat']; $lng = $input['lng'];
        
        $sql = "INSERT INTO bookings (sales_name, customer_name, phone, product_detail, zone, booking_date, time_slot, booking_type, status, lat, lng) 
                VALUES ('$sales_name', '$name', '$phone', '$product', '$zone', '$date', '$slot', '$type', 'pending_approval', '$lat', '$lng')";
        
        if($conn->query($sql)) echo json_encode(["status" => "success"]);
        else echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}

if ($method === 'PUT') {
    $data = json_decode(file_get_contents("php://input"), true);
    $conn->query("UPDATE bookings SET status='" . ($data['action'] === 'approve' ? 'confirmed' : 'rejected') . "' WHERE id=" . $data['id']);
    echo json_encode(["status" => "success"]);
}
?>