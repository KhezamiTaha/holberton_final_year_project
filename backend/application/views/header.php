<div class="navbar-bg"></div>
<nav class="navbar navbar-expand-lg main-navbar">
    <form class="form-inline mr-auto">
        <ul class="navbar-nav mr-3">
            <li><a href="javascript:void(0)" data-toggle="sidebar" class="nav-link nav-link-lg"><em class="fas fa-bars"></em></a></li>
            <li class="nav-item d-none d-sm-inline-block center mr-auto" style="color: white; margin: 5px 0px 0px 20px;">Holberton Quiz</li>
        </ul>
    </form>
    <ul class="navbar-nav navbar-right">
        <li class="dropdown">
            <a href="<?= base_url(); ?>" data-toggle="dropdown" class="nav-link dropdown-toggle  nav-link-lg nav-link-user">
                <span class="user_profile_icon"><i class="fa fa-user-circle" aria-hidden="true"></i> </span>
                <div class="d-sm-none d-lg-inline-block"><?= lang('hi'); ?>, <?= ucwords($this->session->userdata('authName')); ?></div>
            </a>
            <div class="dropdown-menu dropdown-menu-right">

                <a href="<?php echo base_url(); ?>logout" class="dropdown-item has-icon">
                    <em class="fas fa-sign-out-alt"></em> <?= lang('logout'); ?>
                </a>
            </div>
        </li>
    </ul>
</nav>
<div class="main-sidebar">
    <aside id="sidebar-wrapper">
        <ul class="sidebar-menu">
            <div class="sidebar-brand my-1">
                <a href="<?= base_url(); ?>dashboard">
                    <?php if (is_settings('full_logo')) { ?>
                        <img src="<?= base_url() . LOGO_IMG_PATH . is_settings('full_logo'); ?>" alt="logo" width="150" id="full_logo">
                    <?php } ?>
                </a>
            </div>
            <div class="sidebar-brand sidebar-brand-sm">
                <a href="<?= base_url(); ?>dashboard">
                    <?php if (is_settings('half_logo')) { ?>
                        <img src="<?= base_url() . LOGO_IMG_PATH . is_settings('half_logo'); ?>" alt="logo" width="50">
                    <?php } ?>
                </a>
            </div>
            <li>
                <a class="nav-link" href="<?= base_url(); ?>dashboard"><em class="fas fa-home"></em> <span><?= lang('dashboard'); ?></span></a>
            </li>
            <li class="nav-item dropdown">
                <a href="javascript:void(0)" class="nav-link has-dropdown"><em class="fas fa-gift"></em><span><?= lang('quiz_zone'); ?></span></a>
                <ul class="dropdown-menu">

                    <li><a class="nav-link" href="<?= base_url(); ?>main-category"><?= lang('main_category'); ?></a></li>


                    <li><a class="nav-link" href="<?= base_url(); ?>sub-category"><?= lang('sub_category'); ?></a></li>



                    <?php if (has_permissions('read', 'questions')) { ?>
                        <li><a class="nav-link" href="<?= base_url(); ?>create-questions"><?= lang('create_questions'); ?></a></li>
                    <?php } ?>
                    <?php if (has_permissions('read', 'questions')) { ?>
                        <li><a class="nav-link" href="<?= base_url(); ?>manage-questions"><?= lang('view_questions'); ?></a></li>
                    <?php } ?>
                </ul>
            </li>








            <?php if (has_permissions('read', 'users')) { ?>
                <li>
                    <a class="nav-link" href="<?= base_url() ?>users"><em class="fas fa-users"></em> <span><?= lang('users'); ?></span></a>
                </li>
            <?php } ?>
                    <!-- auth status , check if user is allowed to control by the admin -->





   
                <li class="nav-item dropdown">
                    <a href="javascript:void(0)" class="nav-link has-dropdown"><em class="fas fa-cog"></em><span><?= lang('settings'); ?></span></a>
                    <ul class="dropdown-menu">
                        <?php if (has_permissions('read', 'system_configuration')) { ?>
                            <li><a class="nav-link" href="<?= base_url(); ?>system-configurations"><?= lang('system_configurations'); ?></a></li>
                        <?php } ?>


                        <?php if (has_permissions('read', 'system_configuration')) { ?>
                            <li><a class="nav-link" href="<?= base_url(); ?>system-utilities"><?= lang('system_utilities'); ?></a></li>
                        <?php } ?>




                    </ul>
                </li>
      





        </ul>
    </aside>
</div>