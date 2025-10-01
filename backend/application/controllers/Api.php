<?php

/** @intelephense-ignore */

defined('BASEPATH') or exit('No direct script access allowed');

require APPPATH . '/libraries/REST_Controller.php';
require FCPATH . 'vendor/autoload.php';

use Kreait\Firebase\Factory;


class Api extends REST_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        // Default image
        $this->NO_IMAGE = base_url() . LOGO_IMG_PATH . is_settings('half_logo');

        date_default_timezone_set(get_system_timezone());

        $this->toDate = date('Y-m-d');
        $this->toDateTime = date('Y-m-d H:i:s');
        $this->toContestDateTime = date('Y-m-d H:i:00');
        $this->load->library('JWT');
        $jwtKey = $this->db->where('type', 'jwt_key')->get('tbl_settings')->row_array();
        $jwtKey = $jwtKey['message'];
        $this->JWT_SECRET_KEY = "$jwtKey";

        $questionShuffleMode = $this->db->where('type', 'question_shuffle_mode')->get('tbl_settings')->row_array();
        $questionShuffleMode = $questionShuffleMode['message'];
        if ($questionShuffleMode) {
            $this->Order_By = 'rand()';
        } else {
            $this->Order_By = 'id';
        }

        $optionShuffleMode = $this->db->where('type', 'option_shuffle_mode')->get('tbl_settings')->row_array();
        $optionShuffleMode = $optionShuffleMode['message'];
        $this->OPTION_SHUFFLE_MODE = "$optionShuffleMode";

        $this->DASHING_DEBUT = 'dashing_debut';
        $this->COMBAT_WINNER = 'combat_winner';
        $this->CLASH_WINNER = 'clash_winner';
        $this->MOST_WANTED_WINNER = 'most_wanted_winner';
        $this->ULTIMATE_PLAYER = 'ultimate_player';
        $this->QUIZ_WARRIOR = 'quiz_warrior';
        $this->SUPER_SONIC = 'super_sonic';
        $this->FLASHBACK = 'flashback';
        $this->BRAINIAC = 'brainiac';
        $this->BIG_THING = 'big_thing';
        $this->ELITE = 'elite';
        $this->THIRSTY = 'thirsty';
        $this->POWER_ELITE = 'power_elite';
        $this->SHARING_CARING = 'sharing_caring';
        $this->STREAK = 'streak';
        $this->refer_coin_msg = 'usedReferCode';
        $this->earn_coin_msg = 'referCodeToFriend';
        $this->opening_msg = 'welcomeBonus';
        $this->watched_ads = 'watchedAds';
    }

    public function user_signup_post()
    {

        if ($this->post('firebase_id') && $this->post('type') && ($this->post('firebase_id') != 'null') && ($this->post('firebase_id') != 'NULL')) {
            $firebase_id = $this->post('firebase_id');

            // ------- Should be Enabled for server  ----------
            $is_verify = $this->verify_user($firebase_id);
            // ---------------------------------------------------
            // ------- Should be Disable for server  ----------
            // $is_verify=true;
            // ---------------------------------------------------
            if ($is_verify) {
                $type = $this->post('type');
                $email = ($this->post('email')) ? $this->post('email') : '';
                $name = ($this->post('name')) ? $this->post('name') : '';
                $mobile = ($this->post('mobile')) ? $this->post('mobile') : '';
                $profile = ($this->post('profile')) ? $this->post('profile') : '';
                $fcm_id = ($this->post('fcm_id')) ? $this->post('fcm_id') : '';
                $friends_code = ($this->post('friends_code')) ? $this->post('friends_code') : '';
                $status = ($this->post('status')) ? $this->post('status') : '1';
                $refer_coin = is_settings('refer_coin');
                $earn_coin = is_settings('earn_coin');

                if (!empty($friends_code)) {
                    $code = valid_friends_refer_code($friends_code);
                    if (!$code['is_valid']) {
                        $friends_code = '';
                    }
                }
                $res = $this->db->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();
                if (!empty($res)) {
                    if ($res['status'] == 1) {
                        $user_id = $res['id'];
                        $refer_code = $this->random_string(4) . $res['refer_code'];

                        $friends_code_is_used = check_friends_code_is_used_by_user($user_id);
                        if (!$friends_code_is_used['is_used'] && $friends_code != '') {
                            $data = array('friends_code' => $friends_code);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                            //update coins
                            $this->set_coins($user_id, $refer_coin);
                            // set tracker data
                            $this->set_tracker_data($user_id, $refer_coin, $this->refer_coin_msg, 0);

                            $credited = credit_coins_to_friends_code($friends_code);
                            if ($credited['credited']) {
                                $this->set_coins($credited['user_id'], $credited['coins'], false);
                                // set tracker data
                                $this->set_tracker_data($credited['user_id'], $earn_coin, $this->earn_coin_msg, 0);
                                // for sharing is caring badge
                                $friends = $this->db->where('friends_code', $friends_code)->get('tbl_users')->result_array();
                                $friends_counter = count($friends);
                                $this->set_coins($credited['user_id'], $friends_counter, false, $type = 'sharing_caring');
                            }
                        }
                        if (!empty($fcm_id)) {
                            $data = array('fcm_id' => $fcm_id);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }
                        if (!is_refer_code_set($user_id) && !empty($refer_code)) {
                            $data = array('refer_code' => $refer_code);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }
                        if (!empty($name)) {
                            $data = array('name' => $name);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }

                        //generate token
                        $api_token = $this->generate_token($user_id, $firebase_id);
                        $this->db->where('id', $user_id)->update('tbl_users', ['api_token' => $api_token]);

                        $res1 = $this->db->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();

                        if (filter_var($res['profile'], FILTER_VALIDATE_URL) === false) {
                            $res1['profile'] = ($res1['profile']) ? base_url() . USER_IMG_PATH . $res1['profile'] : '';
                        }
                        $response['error'] = false;
                        $response['message'] = "105";
                        $response['data'] = $res1;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "126";
                    }
                } else {
                    $data = array(
                        'firebase_id' => $firebase_id,
                        'name' => $name,
                        'email' => $email,
                        'mobile' => $mobile,
                        'type' => $type,
                        'profile' => $profile,
                        'fcm_id' => $fcm_id,
                        'friends_code' => $friends_code,
                        'coins' => '0',
                        'status' => $status,
                        'date_registered' => $this->toDateTime,
                    );
                    $this->db->insert('tbl_users', $data);
                    $insert_id = $this->db->insert_id();

                    // get the welcome bonus result from settings 
                    $welcome_bonus_query = $this->db->select('message')->where('type', 'welcome_bonus_coin')->get('tbl_settings')->row_array();

                    // get the welcome bonus data if not found then default will be 5
                    $welcome_bonus_coins = (int)$welcome_bonus_query['message'] ?? 5;

                    //set the welcome bonus entry in table :- tracker
                    $this->set_tracker_data($insert_id, $welcome_bonus_coins, $this->opening_msg, 0);

                    //add coins to users
                    $this->db->where('id', $insert_id)->update('tbl_users', ['coins' => $welcome_bonus_coins]);

                    //generate token
                    $api_token = $this->generate_token($insert_id, $firebase_id);
                    $this->db->where('id', $insert_id)->update('tbl_users', ['api_token' => $api_token]);

                    $counter = 0;
                    $badges = [
                        'user_id' => $insert_id,
                        'dashing_debut' => $counter,
                        'dashing_debut_counter' => $counter,
                        'combat_winner' => $counter,
                        'combat_winner_counter' => $counter,
                        'clash_winner' => $counter,
                        'clash_winner_counter' => $counter,
                        'most_wanted_winner' => $counter,
                        'most_wanted_winner_counter' => $counter,
                        'ultimate_player' => $counter,
                        'quiz_warrior' => $counter,
                        'quiz_warrior_counter' => $counter,
                        'super_sonic' => $counter,
                        'flashback' => $counter,
                        'brainiac' => $counter,
                        'big_thing' => $counter,
                        'elite' => $counter,
                        'thirsty' => $counter,
                        'thirsty_date' => '0000-00-00',
                        'thirsty_counter' => $counter,
                        'power_elite' => $counter,
                        'power_elite_counter' => $counter,
                        'sharing_caring' => $counter,
                        'streak' => $counter,
                        'streak_date' => '0000-00-00',
                        'streak_counter' => $counter,
                    ];
                    $this->db->insert('tbl_users_badges', $badges);

                    $refer_code = $this->random_string(4) . $insert_id;
                    $dataR = array('refer_code' => $refer_code);
                    $this->db->where('id', $insert_id)->update('tbl_users', $dataR);

                    if ($friends_code != '') {
                        $data = array('coins' => $refer_coin);
                        $this->db->where('id', $insert_id)->update('tbl_users', $data);
                        $this->set_tracker_data($insert_id, $refer_coin, $this->refer_coin_msg, 0);
                        $credited = credit_coins_to_friends_code($friends_code);
                        if ($credited['credited']) {
                            $this->set_coins($credited['user_id'], $credited['coins'], false);
                            $this->set_tracker_data($credited['user_id'], $earn_coin, $this->earn_coin_msg, 0);
                            // for sharing is caring badge
                            $friends = $this->db->where('friends_code', $friends_code)->get('tbl_users')->result_array();
                            $friends_counter = count($friends);
                            $this->set_coins($credited['user_id'], $friends_counter, false, $type = 'sharing_caring');
                        }
                    }

                    $res1 = $this->db->where('id', $insert_id)->get('tbl_users')->row_array();

                    if (filter_var($res1['profile'], FILTER_VALIDATE_URL) === false) {
                        $res1['profile'] = ($res1['profile']) ? base_url() . USER_IMG_PATH . $res1['profile'] : '';
                    }
                    $response['error'] = false;
                    $response['message'] = "104";
                    $response['data'] = $res1;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "129";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }





    public function get_bookmark_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('type')) {
            $type = $this->post('type');

            if ($type == 3 || $type == '3') {
                $this->db->select('b.*, q.language_id, q.category, q.subcategory, q.image, q.question, q.answer');
                $this->db->join('tbl_guess_the_word q', 'q.id=b.question_id');
            } else if ($type == 4 || $type == '4') {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.audio_type, q.audio, q.question, q.question_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.note');
                $this->db->join('tbl_audio_question q', 'q.id=b.question_id');
            } else if ($type == 5 || $type == '5') {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.image, q.question, q.question_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.note');
                $this->db->join('tbl_maths_question q', 'q.id=b.question_id');
            } else {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.image, q.question, q.question_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.level, q.note');
                $this->db->join('tbl_question q', 'q.id=b.question_id');
            }
            $this->db->where('b.type', $type);
            $this->db->where('b.user_id', $user_id)->order_by('b.id', 'DESC');
            $data = $this->db->get('tbl_bookmark b')->result_array();
            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    if ($type == 3 || $type == '3') {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . GUESS_WORD_IMG_PATH . $data[$i]['image'] : '';
                    } else if ($type == 4 || $type == '4') {
                        $data[$i]['audio'] = ($data[$i]['audio']) ? (($data[$i]['audio_type'] != '1') ? base_url() . QUESTION_AUDIO_PATH : '') . $data[$i]['audio'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                    } else if ($type == 5 || $type == '5') {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MATHS_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                    } else {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                    }
                }
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = false;
                $response['data'] = $data;
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_bookmark_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('question_id') && $this->post('status') != '' && $this->post('type')) {
            $question_id = $this->post('question_id');
            $status = $this->post('status');
            $type = $this->post('type');

            if ($status == '1' || $status == 1) {
                $frm_data = array(
                    'user_id' => $user_id,
                    'question_id' => $question_id,
                    'status' => $status,
                    'type' => $type,
                );
                $this->db->insert('tbl_bookmark', $frm_data);
            } else {
                $this->db->where('user_id', $user_id)->where('question_id', $question_id)->delete('tbl_bookmark');
            }
            $response['error'] = false;
            $response['message'] = "111";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_notifications_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        $get_user_data = $this->db->select('date_registered')->where('id', $user_id)->get('tbl_users')->row_array();
        $register_date = date('Y-m-d', strtotime($get_user_data['date_registered']));

        $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 10;
        $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;

        $sort = ($this->post('sort')) ? $this->post('sort') : 'id';
        $order = ($this->post('order')) ? $this->post('order') : 'DESC';

        $this->db->select('id,title,message,users,type,type_id,image,date_sent')
            ->from('tbl_notifications n')
            ->where('DATE(n.date_sent) >=', $register_date)
            ->group_start()
            ->where('n.users', 'all')
            ->or_where('FIND_IN_SET(' . $user_id . ', n.user_id) >', 0)
            ->group_end()
            ->order_by($sort, $order)
            ->limit($limit, $offset);
        $result = $this->db->get()->result_array();

        $this->db->select('COUNT(*) as total')
            ->from('tbl_notifications n')
            ->where('DATE(n.date_sent) >=', $register_date)
            ->group_start()
            ->where('n.users', 'all')
            ->or_where('FIND_IN_SET(' . $user_id . ', n.user_id) >', 0)
            ->group_end();
        $total = $this->db->get()->row()->total;

        if (!empty($result)) {
            for ($i = 0; $i < count($result); $i++) {
                if (filter_var($result[$i]['image'], FILTER_VALIDATE_URL) === false) {
                    /* Not a valid URL. Its a image only or empty */
                    $result[$i]['image'] = (!empty($result[$i]['image'])) ? base_url() . NOTIFICATION_IMG_PATH . $result[$i]['image'] : '';
                }
            }
            $response['error'] = false;
            $response['total'] = "$total";
            $response['data'] = $result;
        } else {
            $response['error'] = true;
            $response['message'] = "102";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_user_by_id_post()
    {

        // ------- Should be Enabled for server  ----------
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
            $user_status = $is_user['status'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        // ---------------------------------------------------

        // ------- Should be Disable for server  ----------
        // $user_id = $this->post('user_id');
        // $firebase_id = $this->post('firebase_id');
        // ------------------------------------------------


        if ($user_status == 1) {
            if ($firebase_id) {
                // /* Check User Daily Ads Counter */
                $dailyAdsCoinQuery = $this->db->select('message')->where('type', 'daily_ads_coins')->get('tbl_settings')->row_array();
                $dailyAdsCoin = $dailyAdsCoinQuery['message'];

                // Get Daily Ads Counter from Settings
                $dailyAdsCounterQuery = $this->db->select('message')->where('type', 'daily_ads_counter')->get('tbl_settings')->row_array();
                $dailyAdsCounter = $dailyAdsCounterQuery['message'];

                // Get User Daily Ads Counter And Date            
                $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
                $userCounter = $res['daily_ads_counter'];
                $userDailyAdsDate = $res['daily_ads_date'];

                // Convert Date to string time 
                $dailyAdsDate = strtotime($userDailyAdsDate);
                $currentDate = strtotime(date('Y-m-d'));

                if ($currentDate != $dailyAdsDate) {
                    // If Date Doen't match with today's date
                    // Then Update Counter to 0 and date to today's
                    $data = array(
                        'daily_ads_counter' => 0,
                        'daily_ads_date' => date('Y-m-d'),
                    );

                    // Update data and allow the user to watch ads
                    $this->db->where('id', $user_id)->where('firebase_id', $firebase_id)->update('tbl_users', $data);
                    $dailyAdsAvailable = 1;
                } else {
                    if ($dailyAdsCounter == $userCounter) {
                        // If Daily Ads Counter is less than or equal to user's counter then not allow to watch ads
                        $dailyAdsAvailable = 0;
                    } else {
                        // If Daily Ads Counter is greater than or equal to user's counter then allow to watch ads
                        $dailyAdsAvailable = 1;
                    }
                }
                $res = $this->db->select('id, firebase_id, name, email, mobile, type, profile, fcm_id, coins, refer_code, friends_code, status, date_registered,remove_ads')->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();
                if ($res) {
                    $res1 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                    if (empty($res1)) {
                        $counter = 0;
                        $badges = [
                            'user_id' => $user_id,
                            'dashing_debut' => $counter,
                            'dashing_debut_counter' => $counter,
                            'combat_winner' => $counter,
                            'combat_winner_counter' => $counter,
                            'clash_winner' => $counter,
                            'clash_winner_counter' => $counter,
                            'most_wanted_winner' => $counter,
                            'most_wanted_winner_counter' => $counter,
                            'ultimate_player' => $counter,
                            'quiz_warrior' => $counter,
                            'quiz_warrior_counter' => $counter,
                            'super_sonic' => $counter,
                            'flashback' => $counter,
                            'brainiac' => $counter,
                            'big_thing' => $counter,
                            'elite' => $counter,
                            'thirsty' => $counter,
                            'thirsty_date' => '0000-00-00',
                            'thirsty_counter' => $counter,
                            'power_elite' => $counter,
                            'power_elite_counter' => $counter,
                            'sharing_caring' => $counter,
                            'streak' => $counter,
                            'streak_date' => '0000-00-00',
                            'streak_counter' => $counter,
                        ];
                        $this->db->insert('tbl_users_badges', $badges);
                    }

                    if (filter_var($res['profile'], FILTER_VALIDATE_URL) === false) {
                        // Not a valid URL. Its a image only or empty
                        $res['profile'] = ($res['profile']) ? base_url() . USER_IMG_PATH . $res['profile'] : '';
                    }
                    $my_rank = $this->db->query("SELECT r.score,r.user_rank FROM (SELECT s.*, @user_rank := @user_rank + 1 user_rank FROM ( SELECT user_id, sum(score) score  FROM tbl_leaderboard_monthly m join tbl_users u on u.id = m.user_id GROUP BY user_id ) s, (SELECT @user_rank := 0) init ORDER BY score DESC ) r INNER join tbl_users u on u.id = r.user_id WHERE r.user_id=" . $res['id'] . "")->row_array();
                    $res['all_time_score'] = ($my_rank) ? $my_rank['score'] : '0';
                    $res['all_time_rank'] = ($my_rank) ? $my_rank['user_rank'] : '0';
                    $res['daily_ads_available'] = $dailyAdsAvailable ?? 0;

                    $response['error'] = false;
                    $response['data'] = $res;
                } else {
                    $response['error'] = true;
                    $response['message'] = "131";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "126";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function check_user_exists_post()
    {
        if ($this->post('firebase_id')) {
            $firebase_id = $this->post('firebase_id');
            $res = $this->db->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();
            if ($res) {
                $response['error'] = false;
                $response['message'] = "130";
            } else {
                $response['error'] = false;
                $response['message'] = "131";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function upload_profile_image_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        
        if ($user_id && $_FILES['image']['name'] != '') {
            // create folder
            if (!is_dir(USER_IMG_PATH)) {
                mkdir(USER_IMG_PATH, 0777, true);
            }
            $config['upload_path'] = USER_IMG_PATH;
            $config['allowed_types'] = IMG_ALLOWED_WITH_SVG_TYPES;
            $config['file_name'] = time();
            $this->load->library('upload', $config);
            $this->upload->initialize($config);

            if (!$this->upload->do_upload('image')) {
                $response['error'] = true;
                $response['message'] = "107";
            } else {
                $sql1 = $this->db->select('profile')->where('id', $user_id)->get('tbl_users')->row_array();
                if ($sql1['profile'] != "") {
                    $full_url = USER_IMG_PATH . $sql1['profile'];
                    if (file_exists($full_url)) {
                        unlink($full_url);
                    }
                }

                $data = $this->upload->data();
                $img = $data['file_name'];
                // @intelephense-ignore P1008
                if ($_FILES['image']['type'] != 'application/octet-stream' && $_FILES['image']['type'] != 'image/svg+xml') {

                    //image compress
                    $this->load->library('Compress'); // load the codeginiter library

                    $compress = new Compress();
                    $compress->file_url = base_url() . USER_IMG_PATH . $img;
                    $compress->new_name_image = $img;
                    $compress->quality = 80;
                    $compress->destination = base_url() . USER_IMG_PATH;
                    $compress->compress_image();
                }

                $insert_data = array(
                    'profile' => $img,
                );
                $this->db->where('id', $user_id)->update('tbl_users', $insert_data);

                $res = $this->db->select('profile')->where('id', $user_id)->get('tbl_users')->row_array();
                if (filter_var($res['profile'], FILTER_VALIDATE_URL) === false) {
                    // Not a valid URL. Its a image only or empty
                    $res['profile'] = ($res['profile']) ? base_url() . USER_IMG_PATH . $res['profile'] : '';
                }
                $response['error'] = false;
                $response['message'] = '106';
                $response['data'] = $res;
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_user_coin_score_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id) {
            if ($this->post('score')) {
                $score = $this->post('score');
                
            }

            if ($this->post('coins') && $this->post('title') && $this->post('status') != "") {
                $coins = $this->post('coins');
                $this->set_coins($user_id, $coins);
                //set tracker data
                $title = $this->post('title');
                $status = $this->post('status');
                $this->set_tracker_data($user_id, $coins, $title, $status);
            }

            if ($this->post('type') && $this->post('coins') && $this->post('title') && $this->post('status') != "") {
                $type = $this->post('type');
                $this->set_badges_reward($user_id, $type);
            }

            $result = $this->db->select('coins')->where('id', $user_id)->get('tbl_users')->row_array();

            if (!empty($result)) {
                $my_rank = $this->db->query("SELECT r.score,r.user_rank FROM (SELECT s.*, @user_rank := @user_rank + 1 user_rank FROM ( SELECT user_id, sum(score) score FROM tbl_leaderboard_monthly m GROUP BY user_id ) s, (SELECT @user_rank := 0) init ORDER BY score DESC ) r INNER join tbl_users u on u.id = r.user_id WHERE r.user_id=$user_id")->row_array();

                $result['score'] = ($my_rank) ? $my_rank['score'] : '0';

                $response['error'] = false;
                $response['message'] = "111";
                $response['data'] = $result;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function update_profile_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id) {
            $data = array();
            if ($this->post('name')) {
                $data['name'] = $this->post('name');
            }

            if ($this->post('email')) {
                $data['email'] = $this->post('email');
            }
            if ($this->post('mobile')) {
                $data['mobile'] = $this->post('mobile');
            }
            if ($this->post('remove_ads')) {
                if ($this->post('remove_ads') <= 1 && $this->post('remove_ads') > -1) {
                    $data['remove_ads'] = $this->post('remove_ads');
                } else {
                    $response['error'] = false;
                    $response['message'] = "122";
                    $this->response($response, REST_Controller::HTTP_OK);
                    return false;
                }
            }
            $this->db->where('id', $user_id)->update('tbl_users', $data);

            $response['error'] = false;
            $response['message'] = "106";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_categories_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $user_id = 0;
        }
        if ($this->post('type')) {
            $type = $this->post('type');
            $subType = $this->post('sub_type') ?? 0;

            if ($type == 1 || $type == '1') {
                if ($subType) {
                    if ($subType == 1) {
                        $no_of_que = ' (SELECT COUNT(q.id) FROM tbl_question q LEFT JOIN tbl_user_category uc ON q.category = uc.category_id WHERE q.category = c.id AND (c.is_premium = 0 OR (c.is_premium = 1 AND uc.user_id = ' . $user_id . '))) as no_of_que,';
                    } else {
                        $no_of_que = ' (select count(id) from tbl_question q where q.category=c.id AND c.is_premium = 0) as no_of_que,';
                    }
                    $no_of =  '(SELECT @no_of_subcategories := count(`id`) from tbl_subcategory s WHERE s.maincat_id = c.id AND c.is_premium = 0 AND s.status = 1 AND s.id IN (SELECT subcategory FROM tbl_question WHERE subcategory != 0)) as no_of';
                } else {
                    $no_of_que = ' (select count(id) from tbl_question q where q.category=c.id ) as no_of_que,';
                    $no_of =  '(SELECT @no_of_subcategories := count(`id`) from tbl_subcategory s WHERE s.maincat_id = c.id and s.status = 1 AND s.id IN (SELECT subcategory FROM tbl_question WHERE subcategory != 0)) as no_of';
                }
            } else if ($type == 2 || $type == '2') {
                $no_of_que = ' (select count(id) from tbl_fun_n_learn q where q.category=c.id AND q.status=1) as no_of_que,';
                $no_of =  '(SELECT @no_of_subcategories := count(`id`) from tbl_subcategory s WHERE s.maincat_id = c.id and s.status = 1 AND s.id IN (SELECT subcategory FROM tbl_fun_n_learn WHERE subcategory != 0)) as no_of';
            } else if ($type == 3 || $type == '3') {
                $no_of_que = ' (select count(id) from tbl_guess_the_word q where q.category=c.id ) as no_of_que,';
                $no_of =  '(SELECT @no_of_subcategories := count(`id`) from tbl_subcategory s WHERE s.maincat_id = c.id AND s.status = 1 AND s.id IN (SELECT subcategory FROM tbl_guess_the_word WHERE subcategory != 0)) as no_of';
            } else if ($type == 4 || $type == '4') {
                $no_of_que = ' (select count(id) from tbl_audio_question q where q.category=c.id ) as no_of_que,';
                $no_of =  '(SELECT @no_of_subcategories := count(`id`) from tbl_subcategory s WHERE s.maincat_id = c.id AND s.status = 1 AND s.id IN (SELECT subcategory FROM tbl_audio_question WHERE subcategory != 0)) as no_of';
            } else if ($type == 5 || $type == '5') {
                $no_of_que = ' (select count(id) from tbl_maths_question q where q.category=c.id ) as no_of_que,';
                $no_of =  '(SELECT @no_of_subcategories := count(`id`) from tbl_subcategory s WHERE s.maincat_id = c.id AND s.status = 1 AND s.id IN (SELECT subcategory FROM tbl_maths_question WHERE subcategory != 0)) as no_of';
            }

            if ($user_id) {
                $this->db->select('c.*,' . $no_of . ',' . $no_of_que . ' if(@no_of_subcategories = 0, (SELECT @maxlevel := MAX(`level`+0) from tbl_question q WHERE c.id = q.category ),@maxlevel := 0) as maxlevel, (SELECT count(*) from tbl_user_category uc WHERE uc.category_id = c.id and uc.user_id = ' . $user_id . ' ) as has_unlocked');
            } else {
                $this->db->select('c.*,' . $no_of . ',' . $no_of_que . ' if(@no_of_subcategories = 0, (SELECT @maxlevel := MAX(`level`+0) from tbl_question q WHERE c.id = q.category ),@maxlevel := 0) as maxlevel');
            }
            $this->db->where('type', $type);
            if ($this->post('id')) {
                $id = $this->post('id');
                $this->db->where('id', $id);
            }
            if ($this->post('language_id')) {
                $language_id = $this->post('language_id');
                $this->db->where('language_id', $language_id);
            }
            $this->db->having('no_of_que >', 0); // check that no of questions should be more than 0
            $this->db->order_by('row_order', 'ASC');
            $data = $this->db->get('tbl_category c')->result_array();
            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    $data[$i]['image'] = $data[$i]['image'] ? base_url() . CATEGORY_IMG_PATH . $data[$i]['image'] : '';
                    $data[$i]['maxlevel'] = $data[$i]['maxlevel'] == '' || $data[$i]['maxlevel'] == null ? '0' : $data[$i]['maxlevel'];
                    if ($user_id) {
                        //check if category played or not
                        $res = $this->db->where('category', $data[$i]['id'])->where('type', $type)->where('user_id', $user_id)->get('tbl_quiz_categories')->row_array();
                        $data[$i]['is_play'] = !empty($res) ? '1' : '0';
                        $data[$i]['has_unlocked'] = $data[$i]['has_unlocked'] ? '1' : '0';
                    }
                }
                $response['error'] = false;
                $response['subType'] = $subType;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = '102';
            }
        } else {
            $response['error'] = true;
            $response['message'] = '103';
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_by_level_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {

            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {

            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        if ($this->post('level') && ($this->post('category') || $this->post('subcategory'))) {
            $level = $this->post('level');
            $language_id = ($this->post('language_id')) ? $this->post('language_id') : 0;
            $category_id = $this->post('category');
            $subcategory_id = $this->post('subcategory');
            $fix_question = is_settings('quiz_zone_fix_level_question');
            $limit = is_settings('quiz_zone_total_level_question');

            $this->db->select('tbl_question.*,cat.slug as category_slug,subcat.slug as subcategory_slug');
            $this->db->where('level', $level);
            $this->db->join('tbl_category cat', 'cat.id=tbl_question.category', 'left');
            $this->db->join('tbl_subcategory subcat', 'subcat.id=tbl_question.subcategory', 'left');
            if ($this->post('subcategory')) {
                $this->db->where('tbl_question.subcategory', $subcategory_id);
            } else {
                $this->db->where('tbl_question.category', $category_id);
            }
            if (!empty($language_id)) {
                $this->db->where('tbl_question.language_id', $language_id);
            }
            $this->db->order_by($this->Order_By);
            if ($fix_question == 1) {
                $this->db->limit($limit, 0);
            }
            $data = $this->db->get('tbl_question')->result_array();
            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                    $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                }
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }



    public function set_level_data_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('category') && $this->post('level')) {
            $category = $this->post('category');
            $subcategory = ($this->post('subcategory')) ? $this->post('subcategory') : 0;
            $level = $this->post('level');

            $this->db->where('user_id', $user_id)->where('category', $category)->where('subcategory', $subcategory);
            $res = $this->db->get('tbl_level')->result_array();
            if (!empty($res)) {
                $data = array(
                    'level' => $level,
                );
                $this->db->where('user_id', $user_id)->where('category', $category)->where('subcategory', $subcategory)->update('tbl_level', $data);
            } else {
                $frm_data = array(
                    'user_id' => $user_id,
                    'category' => $category,
                    'subcategory' => $subcategory,
                    'level' => $level,
                );
                $this->db->insert('tbl_level', $frm_data);
            }
            $response['error'] = false;
            $response['message'] = "111";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_level_data_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && ($this->post('category') || $this->post('category_slug'))) {
            $category = $this->post('category') ?? 0;
            $categorySlug = !empty($this->post('category_slug')) ? $this->post('category_slug') : null;
            $subcategory = ($this->post('subcategory')) ? $this->post('subcategory') : 0;
            $subcategorySlug = !empty($this->post('subcategory_slug')) ? $this->post('subcategory_slug') : null;

            if ($subcategory) {
                $subcategoryData = $this->db->select("id,maincat_id,subcategory_name,slug")->where('id', $subcategory)->get('tbl_subcategory')->row_array();
                if ($subcategoryData) {
                    $categoryData = $this->getCategoryData($category, $categorySlug);
                    $questionData = $this->getQuestionData($subcategoryData, $categoryData);
                }
            } elseif ($subcategorySlug) {
                $subcategoryData = $this->db->select("id,maincat_id,subcategory_name,slug")->where('slug', $subcategorySlug)->get('tbl_subcategory')->row_array();
                if ($subcategoryData) {
                    $categoryData = $this->getCategoryData($category, $categorySlug);
                    $questionData = $this->getQuestionData($subcategoryData, $categoryData);
                }
            } else {
                $categoryData = $this->getCategoryData($category, $categorySlug);
                $subcategoryData = ['id' => 0];
                $questionData = $this->getQuestionData($subcategoryData, $categoryData);
            }

            if ((isset($categoryData) && !empty($categoryData)) && (isset($subcategoryData) && !empty($subcategoryData))) {
                // Get Level Data with its Particular Question Count
                $max_level = $questionData['max_level'];
                $counter = range(1, $max_level);
                $levelData = [];

                foreach ($counter as $key => $level) {
                    $query = $this->db->query('select count(id) as no_of_que from tbl_question where level = ' . $level . ' and category = ' . $categoryData["id"] . ' and subcategory = ' . $subcategoryData["id"])->row_array();
                    $levelData[$key]['level'] = $level;
                    $levelData[$key]['no_of_ques'] = $query['no_of_que'];
                }

                // Get Data 
                $res = $this->db->select('level')->where('user_id', $user_id)->where('category', $categoryData['id'])->where('subcategory', $subcategoryData['id'])->get('tbl_level')->row_array();
                $data = array(
                    'level' => $res['level'] ?? "1",
                    'no_of_ques' => $questionData['no_of_que'],
                    'max_level' => $questionData['max_level'],
                    'category' => $categoryData ?? [],
                    'subcategory' => $subcategoryData ?? [],
                    'level_data' => $levelData ?? []
                );
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_subcategory_by_maincategory_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && ($this->post('category') || $this->post('category_slug'))) {
            $category = $this->post('category') ?? 0;
            $categorySlug = !empty($this->post('category_slug')) ? $this->post('category_slug') : null;
            $res = $this->getCategoryData($category, $categorySlug);

            if ($res) {
                $type = (!empty($res)) ? $res['type'] : 1;

                if ($type == 1 || $type == '1') {
                    $no_of_que = ' (select count(id) from tbl_question q where q.subcategory=s.id ) as no_of_que,';
                }
                if ($type == 2 || $type == '2') {
                    $no_of_que = ' (select count(id) from tbl_fun_n_learn q where q.subcategory=s.id AND q.status=1) as no_of_que,';
                }
                if ($type == 3 || $type == '3') {
                    $no_of_que = ' (select count(id) from tbl_guess_the_word q where q.subcategory=s.id ) as no_of_que,';
                }
                if ($type == 4 || $type == '4') {
                    $no_of_que = ' (select count(id) from tbl_audio_question q where q.subcategory=s.id ) as no_of_que,';
                }
                if ($type == 5 || $type == '5') {
                    $no_of_que = ' (select count(id) from tbl_maths_question q where q.subcategory=s.id ) as no_of_que,';
                }

                $this->db->select('s.*,`c.category_name as category_name, ' . $no_of_que . ' (select max(`level` + 0) from tbl_question q where q.subcategory=s.id ) as maxlevel, (SELECT count(*) from tbl_user_subcategory us WHERE us.subcategory_id = s.id and us.user_id = ' . $user_id . ' ) as has_unlocked');
                $this->db->join('tbl_category c', 'c.id = s.maincat_id');
                $this->db->where('maincat_id', $res['id']);
                $this->db->where('status', 1);
                $this->db->having('no_of_que >', 0); // check that no of questions should be more than 0
                $this->db->order_by('row_order', 'ASC');
                $data = $this->db->get('tbl_subcategory s')->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . SUBCATEGORY_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i]['maxlevel'] = ($data[$i]['maxlevel'] == '' || $data[$i]['maxlevel'] == null) ? '0' : $data[$i]['maxlevel'];

                        //check if category played or not
                        $res = $this->db->where('subcategory', $data[$i]['id'])->where('category', $data[$i]['maincat_id'])->where('user_id', $user_id)->get('tbl_quiz_categories')->row_array();
                        $data[$i]['is_play'] = (!empty($res)) ? '1' : '0';
                        $data[$i]['has_unlocked'] = $data[$i]['has_unlocked'] ? '1' : '0';
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }











    public function get_questions_by_type_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('type')) {
            $type = $this->post('type');
            $language_id = ($this->post('language_id')) ? $this->post('language_id') : "0";
            $fix_question = is_settings('true_false_quiz_fix_question');
            $limit = is_settings('true_false_quiz_total_question');

            $this->db->select('tbl_question.*,c.id as cat_id, sc.id as subcat_id'); // Select all columns from tbl_question

            $this->db->where('tbl_question.question_type', $type);
            if (!empty($language_id)) {
                $this->db->where('tbl_question.language_id', $language_id);
            }
            $this->db->join('tbl_category c', 'tbl_question.category = c.id')->where('c.is_premium', '0');
            $this->db->join('tbl_subcategory sc', 'tbl_question.subcategory = sc.id', 'left');
            $this->db->order_by($this->Order_By);

            if ($fix_question == 1 && $limit) {
                $this->db->limit($limit, 0);
            }

            $data = $this->db->get('tbl_question')->result_array();

            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                    $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                }
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }




    public function get_users_statistics_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id) {
            $result = $this->db->query("SELECT us.*,u.name,u.profile,(SELECT category_name FROM tbl_category c WHERE c.id=us.strong_category) as strong_category, (SELECT category_name FROM tbl_category c WHERE c.id=us.weak_category) as weak_category FROM tbl_users_statistics us LEFT JOIN tbl_users u on u.id = us.user_id WHERE user_id=$user_id")->result_array();

            if (!empty($result)) {
                if ($result[0]['strong_category'] == null) {
                    $result[0]['strong_category'] = "0";
                }
                if ($result[0]['weak_category'] == null) {
                    $result[0]['weak_category'] = "0";
                }
                if ($result[0]['questions_answered'] == null) {
                    $result[0]['questions_answered'] = "0";
                }
                if ($result[0]['correct_answers'] == null) {
                    $result[0]['correct_answers'] = "0";
                }
                if ($result[0]['strong_category'] == null) {
                    $result[0]['strong_category'] = "0";
                }
                if ($result[0]['best_position'] == null) {
                    $result[0]['best_position'] = "0";
                }
                if (filter_var($result[0]['profile'], FILTER_VALIDATE_URL) === false) {
                    // Not a valid URL. Its a image only or empty
                    $result[0]['profile'] = (!empty($result[0]['profile'])) ? base_url() . USER_IMG_PATH . $result[0]['profile'] : '';
                }
                $response['error'] = false;
                $response['data'] = $result[0];
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_users_statistics_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('questions_answered') && $this->post('correct_answers') != '' && $this->post('category_id') != '' && $this->post('ratio') != '') {
            $questions_answered = $this->post('questions_answered');
            $correct_answers = $this->post('correct_answers');
            $category_id = $this->post('category_id');
            $ratio = $this->post('ratio');

            $res = $this->db->where('user_id', $user_id)->get('tbl_users_statistics')->row_array();

            if (!empty($res)) {
                $type = 'big_thing';
                $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                if (!empty($res2)) {
                    if ($res2[$type] == 0 || $res2[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            
                        }
                    }
                }

                $qa = $res['questions_answered'];
                $ca = $res['correct_answers'];
                $sc = $res['strong_category'];
                $r1 = $res['ratio1'];
                $wc = $res['weak_category'];
                $r2 = $res['ratio2'];
                $bp = $res['best_position'];

                $my_rank = $this->db->query("SELECT r.* FROM (SELECT s.*, @user_rank := @user_rank + 1 user_rank  FROM (SELECT user_id, sum(score) score FROM tbl_leaderboard_monthly m GROUP BY user_id ) s, (SELECT @user_rank := 0) init ORDER BY score DESC ) r INNER join tbl_users u on u.id = r.user_id WHERE r.user_id=$user_id")->result_array();

                $rank1 = $my_rank[0]['user_rank'];
                if ($rank1 < $bp || $bp == 0) {
                    $bp = $rank1;
                    $data = array('best_position' => $bp);
                    $this->db->where('user_id', $user_id)->update('tbl_users_statistics', $data);
                }

                if ($ratio > 50) {
                    /* update strong category */
                    /* when ratio is > 50 he is strong in this particular category */
                    $data['questions_answered'] = $qa + $questions_answered;
                    $data['correct_answers'] = $ca + $correct_answers;
                    if ($ratio > $r1 || $sc == 0) {
                        $data['strong_category'] = $category_id;
                        $data['ratio1'] = $ratio;
                    }
                } else {
                    /* update weak category */
                    /* when ratio is < 50 he is weak in this particular category */
                    $data['questions_answered'] = $qa + $questions_answered;
                    $data['correct_answers'] = $ca + $correct_answers;
                    if ($ratio < $r2 || $wc == 0) {
                        $data['weak_category'] = $category_id;
                        $data['ratio2'] = $ratio;
                    }
                }
                $data['best_position'] = $bp;
                $this->db->where('user_id', $user_id)->update('tbl_users_statistics', $data);

                $response['error'] = false;
                $response['message'] = "111";
            } else {
                if ($ratio > 50) {
                    $frm_data = array(
                        'user_id' => $user_id,
                        'questions_answered' => $questions_answered,
                        'correct_answers' => $correct_answers,
                        'strong_category' => $category_id,
                        'ratio1' => $ratio,
                        'weak_category' => 0,
                        'ratio2' => 0,
                        'best_position' => 0,
                        'date_created' => $this->toDateTime,
                    );
                } else {
                    $frm_data = array(
                        'user_id' => $user_id,
                        'questions_answered' => $questions_answered,
                        'correct_answers' => $correct_answers,
                        'strong_category' => 0,
                        'ratio1' => 0,
                        'weak_category' => $category_id,
                        'ratio2' => $ratio,
                        'best_position' => 0,
                        'date_created' => $this->toDateTime,
                    );
                }
                $this->db->insert('tbl_users_statistics', $frm_data);
                $response['error'] = false;
                $response['message'] = "111";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }



    public function get_system_configurations_post()
    {
        $setting = [
            'system_timezone',
            'system_timezone_gmt',
            'app_link',
            'ios_app_link',
            'refer_coin',
            'earn_coin',
            'reward_coin',
            'app_version',
            'app_version_ios',
            'shareapp_text',
            'language_mode',
            'force_update',
            'daily_quiz_mode',
            'in_app_purchase_mode',
            'in_app_ads_mode',
            'ads_type',
            'android_banner_id',
            'android_interstitial_id',
            'android_rewarded_id',
            'ios_banner_id',
            'ios_interstitial_id',
            'ios_rewarded_id',
            'android_game_id',
            'ios_game_id',
            'payment_mode',
            'per_coin',
            'coin_amount',
            'currency_symbol',
            'coin_limit',
            'app_maintenance',
            'bot_image',
            'daily_ads_visibility',
            'daily_ads_coins',
            'daily_ads_counter',
            'maximum_winning_coins',
            'minimum_coins_winning_percentage',
            'quiz_winning_percentage',
            'score',
            'answer_mode',
            'review_answers_deduct_coin',
            'quiz_zone_mode',
            'quiz_zone_duration',
            'quiz_zone_lifeline_deduct_coin',
            'quiz_zone_wrong_answer_deduct_score',
            'quiz_zone_correct_answer_credit_score',
            'guess_the_word_question',
            'guess_the_word_seconds',
            'guess_the_word_max_hints',
            'guess_the_word_max_winning_coin',
            'guess_the_word_wrong_answer_deduct_score',
            'guess_the_word_correct_answer_credit_score',
            'audio_mode_question',
            'audio_quiz_seconds',
            'audio_quiz_wrong_answer_deduct_score',
            'audio_quiz_correct_answer_credit_score',
            'maths_quiz_mode',
            'maths_quiz_seconds',
            'maths_quiz_wrong_answer_deduct_score',
            'maths_quiz_correct_answer_credit_score',
            'fun_n_learn_question',
            'fun_and_learn_time_in_seconds',
            'fun_n_learn_quiz_wrong_answer_deduct_score',
            'fun_n_learn_quiz_correct_answer_credit_score',
            'true_false_mode',
            'true_false_quiz_in_seconds',
            'true_false_quiz_wrong_answer_deduct_score',
            'true_false_quiz_correct_answer_credit_score',
            'battle_mode_one',
            'battle_mode_one_category',
            'battle_mode_one_in_seconds',
            'battle_mode_one_wrong_answer_deduct_score',
            'battle_mode_one_correct_answer_credit_score',
            'battle_mode_one_quickest_correct_answer_extra_score',
            'battle_mode_one_second_quickest_correct_answer_extra_score',
            'battle_mode_one_code_char',
            'battle_mode_one_entry_coin',
            'battle_mode_group',
            'battle_mode_group_category',
            'battle_mode_group_in_seconds',
            'battle_mode_group_wrong_answer_deduct_score',
            'battle_mode_group_correct_answer_credit_score',
            'battle_mode_group_quickest_correct_answer_extra_score',
            'battle_mode_group_second_quickest_correct_answer_extra_score',
            'battle_mode_group_code_char',
            'battle_mode_group_entry_coin',
            'battle_mode_random',
            'battle_mode_random_category',
            'battle_mode_random_in_seconds',
            'battle_mode_random_wrong_answer_deduct_score',
            'battle_mode_random_correct_answer_credit_score',
            'battle_mode_random_quickest_correct_answer_extra_score',
            'battle_mode_random_second_quickest_correct_answer_extra_score',
            'battle_mode_random_search_duration',
            'battle_mode_random_entry_coin',
            'self_challenge_mode',
            'self_challenge_max_minutes',
            'self_challenge_max_questions',
            'exam_module',
            'exam_module_resume_exam_timeout',
            'contest_mode',
            'contest_mode_wrong_deduct_score',
            'contest_mode_correct_credit_score',
            'latex_mode',
            'exam_latex_mode',
            'gmail_login',
            'email_login',
            'phone_login',
            'apple_login'
        ];
        foreach ($setting as $row) {
            $data = $this->db->where('type', $row)->get('tbl_settings')->row_array();
            if ($row == 'bot_image') {
                $res[$row] = ($data) ? base_url() . LOGO_IMG_PATH . $data['message'] : base_url() . LOGO_IMG_PATH . 'bot-stock.png';
            } else {
                $res[$row] = ($data) ? $data['message'] : '';
            }
        }
        if (!empty($res)) {
            $response['error'] = false;
            $response['data'] = $res;
        } else {
            $response['error'] = true;
            $response['message'] = "102";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_coin_store_data_post()
    {
        $data = $this->db->where('status', 1)->order_by('id', 'asc')->get('tbl_coin_store')->result_array();
        for ($i = 0; $i < count($data); $i++) {
            $data[$i]['image'] = ($data[$i]['image']) ? base_url() . COIN_STORE_IMG_PATH . $data[$i]['image'] :  $this->NO_IMAGE;
        }
        if (!empty($data)) {
            $response['error'] = false;
            $response['data'] = $data;
        } else {
            $response['error'] = true;
            $response['message'] = "102";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_languages_post()
    {
        if ($this->post('id')) {
            $id = $this->post('id');
            $this->db->where('id', $id);
        }
        $data = $this->db->select('id, language, code, default_active')->where('status', 1)->where('type', 1)->order_by('id', 'ASC')->get('tbl_languages')->result_array();
        if (!empty($data)) {
            $response['error'] = false;
            $response['data'] = $data;
        } else {
            $response['error'] = true;
            $response['message'] = "102";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }



    public function get_settings_post()
    {
        if ($this->post('type')) {
            $type = $this->post('type');
            $res = $this->db->where('type', $type)->get('tbl_settings')->row_array();
            if (!empty($res)) {
                $response['error'] = false;
                $response['data'] = $res['message'];
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $res = $this->db->where('type!=', 'shared_secrets')->get('tbl_settings')->result_array();
            if (!empty($res)) {
                $response['error'] = false;
                $response['data'] = $res;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function report_question_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('question_id') && $user_id && $this->post('message')) {
            $frm_data = array(
                'question_id' => $this->post('question_id'),
                'user_id' => $user_id,
                'message' => $this->post('message'),
                'date' => $this->toDateTime,
            );
            $this->db->insert('tbl_question_reports', $frm_data);
            $response['error'] = false;
            $response['message'] = "109";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('type') && $this->post('id')) {
            $type = $this->post('type');
            $id = $this->post('id');

            $this->db->where($type, $id);
            $this->db->order_by($this->Order_By);
            $data = $this->db->get('tbl_question')->result_array();
            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                    $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                }
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function update_fcm_id_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('fcm_id') && $firebase_id) {
            $fcm_id = $this->post('fcm_id');
            $data = array(
                'fcm_id' => $fcm_id,
            );
            $this->db->where('firebase_id', $firebase_id)->update('tbl_users', $data);
            $response['error'] = false;
            $response['message'] = "111";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }



    public function get_user_badges_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        if ($user_id) {
            $badges = [
                'dashing_debut',
                'combat_winner',
                'clash_winner',
                'most_wanted_winner',
                'ultimate_player',
                'quiz_warrior',
                'super_sonic',
                'flashback',
                'brainiac',
                'big_thing',
                'elite',
                'thirsty',
                'power_elite',
                'sharing_caring',
                'streak',
            ];
            // Get the language_id from the post data or default to 14
            $language_id = $this->post('language_id') ? $this->post('language_id') : 14;
            foreach ($badges as $key => $row) {
                $res[$key] = $this->db->where('type', $row)->where('language_id', $language_id)->get('tbl_badges')->row_array();
                if (empty($res[$key])) {
                    $res[$key] = $this->db->where('type', $row)->where('language_id', 14)->get('tbl_badges')->row_array();
                } else {
                    // Check if label is empty then take label of english language
                    if (empty($res[$key]['badge_label'])) {
                        $res[$key]['badge_label'] = $this->db->select('badge_label')->where('type', $row)->where('language_id', 14)->get('tbl_badges')->row_array();
                    }
                    // Check if note is empty then take note of english language
                    if (empty($res[$key]['badge_note'])) {
                        $res[$key]['badge_note'] = $this->db->select('badge_note')->where('type', $row)->where('language_id', 14)->get('tbl_badges')->row_array();
                    }
                }
                $res[$key]['badge_icon'] = (isset($res[$key]['badge_icon']) && !empty($res[$key]['badge_icon'])) ? base_url() . BADGE_IMG_PATH . $res[$key]['badge_icon'] : "";
                $res1 = $this->db->select($row)->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                $res[$key]['status'] = $res1[$row];
            }
            $response['error'] = false;
            $response['data'] = $res;
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }





    public function delete_user_account_post()
    {
        // ------- Should be Enabled for server  -----------------
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        // --------------------------------------------------------

        // ------- Should be Enabled for local  ------------------
        // $user_id = $this->post('user_id');
        // $firebase_id = $this->post('firebase_id');
        // --------------------------------------------------------

        if ($user_id) {
            $tables = [
                'tbl_bookmark',
                'tbl_contest_leaderboard',
                'tbl_daily_quiz_user',
                'tbl_exam_module_result',
                'tbl_leaderboard_daily',
                'tbl_leaderboard_monthly',
                'tbl_level',
                'tbl_payment_request',
                'tbl_question_reports',
                'tbl_rooms',
                'tbl_tracker',
                'tbl_users_badges',
                'tbl_users_statistics',
            ];

            foreach ($tables as $type) {
                $this->db->where('user_id', $user_id)->delete($type);
            }

            $this->db->where('id', $user_id)->delete('tbl_users');
            $this->db->where('user_id1', $user_id)->delete('tbl_battle_statistics');
            $this->db->where('user_id2', $user_id)->delete('tbl_battle_statistics');

            $response['error'] = false;
            $response['message'] = "111";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_tracker_data_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        if ($user_id && $this->post('coins') && $this->post('title') && $this->post('status') != "") {
            $coins = $this->post('coins');
            $title = $this->post('title');
            $status = $this->post('status');

            $this->set_tracker_data($user_id, $coins, $title, $status);

            $response['error'] = false;
            $response['message'] = "111";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_tracker_data_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        if ($user_id) {
            $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;
            $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 10;
            $type = ($this->post('type') && is_numeric($this->post('type'))) ? $this->post('type') : 0;
            if ($type == 1) {
                $this->db->where('status', 0);
            } else if ($type == 2) {
                $this->db->where('status', 1);
            }

            $this->db->where('user_id', $user_id);
            $this->db->order_by('id', 'DESC');
            $this->db->limit($limit, $offset);
            $data = $this->db->get('tbl_tracker')->result_array();
            if (!empty($data)) {
                if ($type == 1) {
                    $data1 = $this->db->where('user_id', $user_id)->where('status', 0)->order_by('id', 'DESC')->get('tbl_tracker')->result_array();
                } else if ($type == 2) {
                    $data1 = $this->db->where('user_id', $user_id)->where('status', 1)->order_by('id', 'DESC')->get('tbl_tracker')->result_array();
                } else {
                    $data1 = $this->db->where('user_id', $user_id)->order_by('id', 'DESC')->get('tbl_tracker')->result_array();
                }

                $total = count($data1);

                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }



    public function set_quiz_categories_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }
        if ($user_id && $this->post('category') && $this->post('type')) {
            $type = $this->post('type');
            $category = $this->post('category');
            $subcategory = ($this->post('subcategory')) ? $this->post('subcategory') : 0;
            $type_id = ($this->post('type_id')) ? $this->post('type_id') : 0;

            $this->db->where('user_id', $user_id);
            $this->db->where('type', $type)->where('type_id', $type_id);
            $this->db->where('category', $category)->where('subcategory', $subcategory);
            $res = $this->db->get('tbl_quiz_categories')->result_array();
            if (empty($res)) {
                $frm_data = array(
                    'user_id' => $user_id,
                    'type' => $type,
                    'category' => $category,
                    'subcategory' => $subcategory,
                    'type_id' => $type_id,
                );
                $this->db->insert('tbl_quiz_categories', $frm_data);
                $response['error'] = false;
                $response['message'] = "111";
            } else {
                $response['error'] = true;
                $response['message'] = "128";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function unlock_premium_category_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('category')) {
            $category_id = $this->post('category');
            $data = $this->db->where(['user_id' => $user_id, 'category_id' => $category_id])->order_by('id', 'asc')->get('tbl_user_category')->result_array();
            if ($data) {
                $response['error'] = true;
                $response['message'] = "132";
            } else {
                $frm_data = array(
                    'user_id' => $user_id,
                    'category_id' => $category_id,
                );
                $this->db->insert('tbl_user_category', $frm_data);
                $response['error'] = false;
                $response['message'] = "110";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }








    public function get_user_coin_score_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id) {
            $result = $this->db->select('coins')->where('id', $user_id)->get('tbl_users')->row_array();
            if (!empty($result)) {
                $my_rank = $this->db->query("SELECT r.score,r.user_rank FROM (SELECT s.*, @user_rank := @user_rank + 1 user_rank FROM ( SELECT user_id, sum(score) score FROM tbl_leaderboard_monthly m GROUP BY user_id ) s, (SELECT @user_rank := 0) init ORDER BY score DESC ) r INNER join tbl_users u on u.id = r.user_id WHERE r.user_id=$user_id")->row_array();

                $result['score'] = ($my_rank) ? $my_rank['score'] : '0';

                $response['error'] = false;
                $response['data'] = $result;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }



    public function get_system_language_list_post()
    {
        if ($this->post('from')) {
            $from = $this->post('from');
            $this->db->select('name,title');
            switch ($from) {
                case 1:
                    $this->db->select('app_version,app_rtl_support,app_status,app_default')->where('app_status', 1)->where('app_version!=', '0.0.0');
                    break;
                case 2:
                    $this->db->select('web_version,web_rtl_support,web_status,web_default')->where('web_status', 1)->where('web_version!=', '0.0.0');
                    break;
                default:
                    $response = [
                        'error' => true,
                        'message' => "122"
                    ];
                    $this->response($response, REST_Controller::HTTP_OK);
                    return;
            }
            $checkData = $this->db->get('tbl_upload_languages')->result_array();
            if ($checkData) {
                $response = [
                    'error' => false,
                    'data' => $checkData
                ];
            } else {
                $response = [
                    'error' => true,
                    'message' => "102"
                ];
            }
        } else {
            $response = [
                'error' => true,
                'message' => "103"
            ];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_system_language_json_post()
    {
        if ($this->post('from')) {
            $from = $this->post('from');
            $language = $this->post('language') ?? 'english';
            $version = '';
            $rtl_support = '0';
            $status = '0';
            $default = '0';

            switch ($from) {
                case 1:
                    $path = APP_LANGUAGE_FILE_PATH;
                    $sampleFile = 'app_sample_file.json';
                    break;
                case 2:
                    $path = WEB_LANGUAGE_FILE_PATH;
                    $sampleFile = 'web_sample_file.json';
                    break;
                default:
                    $response = [
                        'error' => true,
                        'message' => "122"
                    ];
                    $this->response($response, REST_Controller::HTTP_OK);
                    return;
            }

            $file = $path . $language . '.json';

            if (!file_exists($file)) {
                $file = $path . $sampleFile;
            } else {
                $checkData = $this->db->where('name', $language)->get('tbl_upload_languages')->row_array();
                if ($checkData) {
                    $version = ($from == 1) ? $checkData['app_version'] : $checkData['web_version'];
                    $rtl_support = ($from == 1) ? $checkData['app_rtl_support'] : $checkData['web_rtl_support'];
                    $status = ($from == 1) ? $checkData['app_status'] : $checkData['web_status'];
                    $default = ($from == 1) ? $checkData['app_default'] : $checkData['web_default'];
                }
            }

            $getFileContent = file_get_contents($file);
            $sampleArray = json_decode($getFileContent, true);

            $response = [
                'error' => false,
                'version' => $version,
                'rtl_support' => $rtl_support,
                'status' => $status,
                'default' => $default,
                'data' => $sampleArray
            ];
        } else {
            $response = [
                'error' => true,
                'message' => "103"
            ];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Other Functions used for internally 
     */

    public function get_fcm_id($user_id)
    {
        $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
        return $res['fcm_id'];
    }

   





    public function set_coins($user_id, $coins, $is_update = true, $type = 'elite')
    {
        $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
        if (!empty($res)) {
            if ($is_update) {
                $net_coins = $res['coins'] + $coins;
                $data = [
                    'coins' => $net_coins,
                ];
                $this->db->where('id', $user_id)->update('tbl_users', $data);
            } else {
                $net_coins = $coins;
            }

            if ($type == 'elite') {
                $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                if (!empty($res2)) {
                    if ($res2[$type] == 0 || $res2[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            
                        }
                    }
                }
            }
            if ($type == 'sharing_caring') {
                $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                if (!empty($res2)) {
                    if ($res2[$type] == 0 || $res2[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            
                        }
                    }
                }
            }
        }
    }

    public function set_badges_reward($user_id, $type)
    {
        $res = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
        if (!empty($res)) {
            if ($res[$type] == 1 || $res[$type] == '1') {
                $data1 = [
                    $type => 2,
                ];
                $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
            }
        }
    }


    public function set_tracker_data($user_id, $points, $type, $status)
    {
        $res = $this->db->select('firebase_id, coins')->where('id', $user_id)->get('tbl_users')->row_array();
        if (!empty($res)) {
            $firebase_id = $res['firebase_id'];
            $tracker_res = $this->db->where('user_id', $user_id)->where('uid', $firebase_id)->get('tbl_tracker')->row_array();
            if (empty($tracker_res) && !empty($res['coins'])) {
                $coins = $res['coins'] - $points;
                if ($coins != 0 || $coins != "0") {
                    $tracker_data = [
                        'user_id' => $user_id,
                        'uid' => $firebase_id,
                        'points' => $coins,
                        'type' => $this->opening_msg,
                        'status' => 1,
                        'date' => $this->toDate,
                    ];
                    $this->db->insert('tbl_tracker', $tracker_data);
                }
            }

            $tracker_data = [
                'user_id' => $user_id,
                'uid' => $firebase_id,
                'points' => $points,
                'type' => $type,
                'status' => $status,
                'date' => $this->toDate,
            ];
            $this->db->insert('tbl_tracker', $tracker_data);
        }
    }



    public function random_string($length)
    {
        $characters = 'abC0DefGHij1KLMnop2qR3STu4vwxY5ZABc6dEFgh7IJ8klm9NOPQrstUVWXyz';
        $string = '';
        for ($i = 0; $i < $length; $i++) {
            $string .= $characters[mt_rand(0, strlen($characters) - 1)];
        }
        return $string;
    }

    public function checkBattleExists($match_id)
    {
        $res = $this->db->where('match_id', $match_id)->get('tbl_battle_questions')->result_array();
        if (empty($res)) {
            return false;
        } else {
            return true;
        }
    }

    public function verify_user($firebase_id)
    {
        $firebase_config = 'assets/firebase_config.json';
        if (file_exists($firebase_config)) {
            $factory = (new Factory)->withServiceAccount($firebase_config);
            $firebaseauth = $factory->createAuth();
            try {
                $user = (array) $firebaseauth->getUser($firebase_id);
                if ($user['uid'] == $firebase_id) {
                    return true;
                } else {
                    return false;
                }
            } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
                return false;
            }
        } else {
            return false;
        }
    }

    public function generate_token($user_id, $firebase_id)
    {
        $payload = [
            'iat' => time(), /* issued at time */
            'iss' => 'Quiz',
            'exp' => time() + (30 * 60 * 60 * 24), /* expires after 1 minute */
            'user_id' => $user_id,
            'firebase_id' => $firebase_id,
            'sub' => 'Quiz Authentication',
        ];
        return $this->jwt->encode($payload, $this->JWT_SECRET_KEY);
    }

    public function verify_token()
    {
        try {
            $token = $this->jwt->getBearerToken();
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = $e->getMessage();
            return $response;
        }
        if (!empty($token)) {
            try {
                $res = $this->db->where('api_token', $token)->get('tbl_users')->row_array();
                if (empty($res)) {
                    $response['error'] = true;
                    $response['message'] = '129';
                    return $response;
                } else {
                    $payload = $this->jwt->decode($token, $this->JWT_SECRET_KEY, ['HS256']);
                    if ($payload) {
                        if (isset($payload->user_id) && isset($payload->firebase_id)) {
                            $response['error'] = false;
                            $response['user_id'] = $payload->user_id;
                            $response['firebase_id'] = $payload->firebase_id;
                            $response['firebase_id'] = $payload->firebase_id;
                            $response['status'] = $res['status'];
                            return $response;
                        } else {
                            $response['error'] = true;
                            $response['message'] = '129';
                            return $response;
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = '129';
                        return $response;
                    }
                }
            } catch (Exception $e) {
                $response['error'] = true;
                $response['message'] = $e->getMessage();
                return $response;
            }
        } else {
            $response['error'] = true;
            $response['message'] = "125";
            return $response;
        }
    }

    public function encrypt_data($key, $text)
    {
        $iv = openssl_random_pseudo_bytes(16);
        $key .= "0000";
        $encrypted_data = openssl_encrypt($text, 'aes-256-cbc', $key, 0, $iv);
        $data = array("ciphertext" => $encrypted_data, "iv" => bin2hex($iv));
        return $data;
    }

    function suffleOptions($data, $firebase_id)
    {
        // Create an associative array of options
        $options = array(
            'optiona' => trim($data['optiona']),
            'optionb' => trim($data['optionb']),
        );
        if ($data['question_type'] == 1) {
            $options['optionc'] = trim($data['optionc']);
            $options['optiond'] = trim($data['optiond']);
            if (is_option_e_mode_enabled() && $data['optione'] != null) {
                $options['optione'] = trim($data['optione']);
            }
        }

        // Find the correct answer before shuffling
        $correctAnswer = 'option' . $data['answer'];
        $correctAnswerValue = $options[$correctAnswer];

        // Shuffle the options
        $shuffled_options = $options;
        if ($this->OPTION_SHUFFLE_MODE == 1) {
            shuffle($shuffled_options);
            // Assign the shuffled values back to the original options
            $keys = array_keys($options);
            for ($j = 0; $j < count($keys); $j++) {
                $data[$keys[$j]] = $shuffled_options[$j];
                // Update the correct answer after shuffling
                if ($shuffled_options[$j] == $correctAnswerValue) {
                    $suffledAnswer = chr(ord('a') + $j);  // converts the index $j to a letter like 0 to 'a', 1 to 'b', etc.
                    $data['answer'] = $this->encrypt_data($firebase_id, $suffledAnswer);
                }
            }
        } else {
            $data['answer'] = $this->encrypt_data($firebase_id, trim($data['answer']));
        }
        return $data;
    }

    function getCategoryData($category, $categorySlug)
    {
        if ($category) {
            return $this->db->where('id', $category)->get('tbl_category')->row_array();
        } else if ($categorySlug) {
            return $this->db->where('slug', $categorySlug)->get('tbl_category')->row_array();
        }
        return null;
    }

    function getSubCategoryData($subCategory, $subCategorySlug)
    {
        if ($subCategory) {
            return $this->db->where('id', $subCategory)->get('tbl_subcategory')->row_array();
        } else if ($subCategorySlug) {
            return $this->db->where('slug', $subCategorySlug)->get('tbl_subcategory')->row_array();
        }
        return null;
    }

    function getQuestionData($subcategoryData, $categoryData)
    {
        if ($subcategoryData["id"] != 0) {
            return $this->db->query('select count(id) as no_of_que, MAX(level) as max_level from tbl_question where subcategory  = ' . $subcategoryData["id"])->row_array();
        } else {
            return $this->db->query('select count(id) as no_of_que, MAX(level) as max_level from tbl_question where category = ' . $categoryData["id"] . ' AND subcategory = 0')->row_array();
        }
    }
}
